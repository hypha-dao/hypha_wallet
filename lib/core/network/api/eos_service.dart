import 'dart:async';

import 'package:async/async.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hypha_wallet/core/crypto/eosdart/eosdart.dart';
import 'package:hypha_wallet/core/crypto/seeds_esr/eos_transaction.dart';
import 'package:hypha_wallet/core/local/models/user_auth_data.dart';
import 'package:hypha_wallet/core/local/services/secure_storage_service.dart';
import 'package:hypha_wallet/core/network/api/endpoints.dart';
import 'package:hypha_wallet/core/network/api/remote_config_service.dart';
import 'package:hypha_wallet/core/network/models/token_value.dart';

class EOSService {
  final SecureStorageService secureStorageService;
  final RemoteConfigService remoteConfigService;

  EOSService(this.secureStorageService, this.remoteConfigService);

  EOSClient getEosClientForNetwork(Networks network, {List<String> privateKeys = const []}) {
    return EOSClient(
      baseUrl: remoteConfigService.pushTransactionNodeUrl(network: network),
      privateKeys: privateKeys,
      version: 'v1',
    );
  }

  Future<Result<dynamic>> loginWithCode({
    required String accountName,
    required String loginCode,
    required Networks network,
  }) async {
    final contractName = remoteConfigService.loginContract(network: network);
    final actionName = remoteConfigService.loginAction(network: network);
    final loginTransaction = EOSTransaction.fromAction(
      account: contractName,
      actionName: actionName,
      data: {
        'account_name': accountName,
        'login_code': loginCode,
      },
      authorization: [
        Authorization()
          ..actor = accountName
          ..permission = 'active'
      ],
      network: network,
    );
    return sendTransaction(eosTransaction: loginTransaction, accountName: accountName, network: network);
  }

  Future<Result<dynamic>> transferTokens({
    required String fromAccount,
    required String toAccount,
    required TokenValue tokenValue,
    String memo = '',
    required Networks network,
  }) async {
    final contractName = tokenValue.tokenModel.contract;
    final actionName = 'transfer';
    final transferTransaction = EOSTransaction.fromAction(
      account: contractName,
      actionName: actionName,
      data: {
        'from': fromAccount,
        'to': toAccount,
        'quantity': tokenValue.asFormattedString(),
        'memo': memo,
      },
      authorization: [
        Authorization()
          ..actor = fromAccount
          ..permission = 'active'
      ],
      network: network,
    );
    return sendTransaction(eosTransaction: transferTransaction, accountName: fromAccount, network: network);
  }

  Future<Result<dynamic>> deleteBlockchainAccount({
    required String accountName,
    required Networks network,
  }) async {
    throw 'TBD - implement this';
    // final action = createChangePermissionsAction(accountName, 'owner', ['keys'], ['accounts']);
    // return sendTransaction(eosTransaction: action, accountName: accountName, network: network);
  }

  Future<Result<dynamic>> sendTransaction({
    required EOSTransaction eosTransaction,
    required String accountName,
    required Networks network,
  }) async {
    final actions = eosTransaction.actions.map((e) => e.toEosAction).toList();

    for (final action in actions) {
      if (action.authorization == null || action.authorization == []) {
        action.authorization = [
          Authorization()
            ..actor = accountName
            ..permission = 'active'
        ];
      }
    }
    final transaction = _buildTransaction(actions, accountName);
    final UserAuthData? userAuthData = await secureStorageService.getUserAuthData();

    final eosClient = EOSClient(
      baseUrl: remoteConfigService.pushTransactionNodeUrl(network: network),
      privateKeys: [userAuthData!.eOSPrivateKey.toString()],
      version: 'v1',
    );

    return eosClient
        .pushTransaction(transaction)
        .then((dio.Response response) => _mapEosResponse(response, (dynamic map) {
              return map['transaction_id'];
            }))
        .catchError((error, s) => _mapEosError(error, s));
  }

  FutureOr<Result<T>> _mapEosResponse<T>(dio.Response response, Function modelMapper) {
    if (response.data['transaction_id'] != null) {
      final map = Map<String, dynamic>.from(response.data);
      return ValueResult(modelMapper(map));
    } else {
      return ErrorResult(EosError(response.data['processed']['error_code']));
    }
  }

  Transaction _buildTransaction(List<Action> actions, String? accountName) {
    final transaction = Transaction()
      ..actions = [
        ...actions,
      ];

    return transaction;
  }

  ErrorResult _mapEosError(dynamic error, StackTrace? s) {
    print('mapEosError: $error');
    if (s != null) {
      print('stack: $s');
    }
    return ErrorResult(error);
  }

  Map<String, dynamic> createChangePermissionsAction(
    String account,
    String permission,
    List<String> keys,
    List<String> accounts,
  ) {
    assert(permission == 'active' || permission == 'owner', 'permission must be active or owner');
    final parent = permission == 'owner' ? '' : 'owner';

    final List<Map<String, dynamic>> accountPermissions = accounts
        .map(
          (acct) => {
            'permission': {
              'actor': acct,
              'permission': permission,
            },
            'weight': 1
          },
        )
        .toList();

    final List<Map<String, dynamic>> keyPermissions = keys
        .map(
          (key) => {
            'key': key,
            'weight': 1,
          },
        )
        .toList();

    const threshold = 1;

    print('creating $threshold out of ${accountPermissions.length} permissions for @$permission');

    accountPermissions.sort(
      (a, b) => (a['permission']['actor'] as String).compareTo(b['permission']['actor']),
    );
    keyPermissions.sort(
      (a, b) => (a['key'] as String).compareTo(b['key']),
    );

    final auth = {
      'threshold': threshold,
      'waits': [],
      'accounts': accountPermissions,
      'keys': keyPermissions,
    };

    final action = {
      'account': 'eosio',
      'name': 'updateauth',
      'authorization': [
        {
          'actor': account,
          'permission': 'owner',
        }
      ],
      'data': {
        'account': account,
        'permission': permission,
        'parent': parent,
        'auth': auth,
      },
    };

    print('action to be proposed: $action');

    return action;
  }
}

class EosError extends Error {
  int? errorCode;

  EosError(this.errorCode);
}
