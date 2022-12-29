part of 'di_setup.dart';

Future<void> _registerServicesModule() async {
  /// DIO
  _registerLazySingleton(() => Dio());
  _registerFactoryWithParams<DioClient, String?, String?>(
    (baseUrl, version) => DioClient(
      dio: _getIt<Dio>(),
      baseUrl: baseUrl ?? Endpoints.baseUrl,
      version: version ?? 'v1',
    ),
  );

  /// Services
  _registerLazySingleton(() => UserAccountService(dioClient: _getIt<DioClient>()));
  _registerLazySingleton(() => CryptoAuthService());

  _registerFactoryWithParams<EOSClient, String?, String?>(
    (baseUrl, version) => EOSClient(_getIt<DioClient>(param1: baseUrl, param2: version)),
  );
}
