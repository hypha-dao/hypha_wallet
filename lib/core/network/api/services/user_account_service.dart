import 'package:dio/dio.dart';
import 'package:hypha_wallet/core/logging/log_helper.dart';
import 'package:hypha_wallet/core/network/api/endpoints.dart';
import 'package:hypha_wallet/core/network/api/services/remote_config_service.dart';
import 'package:hypha_wallet/core/network/models/network.dart';
import 'package:hypha_wallet/core/network/models/network_extension.dart';
import 'package:hypha_wallet/core/network/networking_manager.dart';

class UserAccountService {
  final NetworkingManager networkingManager;
  final RemoteConfigService remoteConfigService;

  UserAccountService({required this.networkingManager, required this.remoteConfigService});

  Future<bool> createUserAccount({
    required String code,
    required String accountName,
    required String publicKey,
    required String network,
  }) async {
    final requestBody = {
      'code': code,
      'accountName': accountName,
      'publicKey': publicKey,
      'network': network
    };

    final url = remoteConfigService.accountCreatorEndpoint + Endpoints.createAccount;
    try {
      // ignore: unused_local_variable
      final res = await networkingManager.post(url, data: requestBody);
      return true;
    } catch (error, stackTrace) {
      LogHelper.e('Error in createUserAccount', stacktrace: stackTrace, error: error);
      print('Error creating account');
      print(error);
      if (error is DioException) {
        final dioError = error;
        print('message: ${dioError.message}');
        print('status code: ${dioError.response?.statusCode}');
        print('message: ${dioError.response?.statusMessage}');
        print('dioError: $dioError');
      }
      rethrow;
    }
  }

  Future<bool> isUserAccountAvailable(String accountName, Network network) async {
    final requestBody = {
      'account_name': accountName
    };
    try {
      // ignore: unused_local_variable
      final res = await network.manager.post(Endpoints.getAccount, data: requestBody);
      return false;
    } catch (error, stackTrace) {
      LogHelper.e('Error in isUserAccountAvailable', stacktrace: stackTrace, error: error);
      return true;
    }
  }

  Future<String> findAvailableUserAccount(String fullName, Network network) async {
    var sequence = 0;
    final maxTries = 100;

    while (sequence < maxTries) {
      final accountName = generateUserName(fullName: fullName, sequence: sequence);
      if (accountName != null) {
        final bool available = await isUserAccountAvailable(accountName, network);
        if (available) {
          return accountName;
        }
      }
      sequence++;
    }

    return generateUserName(fullName: fullName)!;
  }

  /// Generate a valid EOSIO account name from an input name; generates
  /// unique name for each sequence number.
  ///
  /// Result is always 12 characters long, containing letters [a-z] and numbers [1-5]
  ///
  /// full name: Any string, e.g. 'Jhonny Hypha'
  /// sequence: generator sequence number - each unique sequence number generates a unique
  /// valid EOS account name.
  ///
  /// Returns null if the sequence name is a duplicate
  String? generateUserName({required String fullName, int sequence = 0}) {
    String suggestedUsername = fullName.toLowerCase().trim().split('').map((character) {
      // ignore: unnecessary_raw_strings
      final legalChar = RegExp(r'[a-z]|1|2|3|4|5').allMatches(character).isNotEmpty;
      return legalChar ? character : '';
    }).join();

    suggestedUsername = suggestedUsername.padRight(12, '1');

    suggestedUsername = suggestedUsername.substring(0, 12);

    if (sequence > 0) {
      print('$sequence radix ${(sequence - 1).toRadixString(5)}');
      final postfix = (sequence - 1).toRadixString(5).split('').map((e) => e.incrementString()).join();
      print('postfix $postfix');
      final sequenceName = suggestedUsername.replaceRange(12 - postfix.length, 12, postfix);
      if (sequenceName == suggestedUsername) {
        return null;
      } else {
        suggestedUsername = sequenceName;
      }
    }

    return suggestedUsername;
  }
}

extension NumString on String {
  /// add 1 to a number,e.g '2' -> '3'
  String incrementString() {
    return (int.parse(this) + 1).toString();
  }
}
