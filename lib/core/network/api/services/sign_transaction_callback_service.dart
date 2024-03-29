import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hypha_wallet/core/network/networking_manager.dart';

class SignTransactionCallbackService {
  final String transactionIdQueryParameterName = 'tx_id';

  final NetworkingManager _networkingManager;

  SignTransactionCallbackService(this._networkingManager);

  Future<Response> callTheCallback(String callback, String transactionId) async {
    final uri = Uri.parse(callback);
    final queryParameters = Map.from(uri.queryParameters);
    queryParameters[transactionIdQueryParameterName] = transactionId;

    final body = jsonEncode(queryParameters);
    final path = uri.replace(query: '');

    return _networkingManager.post(path.toString(), data: body);
  }
}
