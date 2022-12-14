import 'package:fimber/fimber.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hypha_wallet/core/logging/firebase_crash_reporting_tree.dart';
import 'package:hypha_wallet/core/repository/auth_repository.dart';
import 'package:hypha_wallet/core/repository/hypha_shared_prefs.dart';
import 'package:hypha_wallet/firebase_options.dart';
import 'package:hypha_wallet/ui/blocs/authentication/authentication_bloc.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

part 'api_module.dart';
part 'bloc_module.dart';
// part 'core_module.dart';
part 'firebase_module.dart';
part 'log_module.dart';
part 'repositories_module.dart';
part 'shared_preferences_module.dart';
part 'usecases_module.dart';

final _getIt = GetIt.I;

// Get It Library wrappers
// void _registerSingleton<T extends Object>(T dependency) => _getIt.registerSingleton<T>(dependency);

void _registerLazySingleton<T extends Object>(FactoryFunc<T> factoryFunc) =>
    _getIt.registerLazySingleton<T>(factoryFunc);

void _registerFactory<T extends Object>(FactoryFunc<T> factoryFunc) => _getIt.registerFactory<T>(factoryFunc);

// Register factory with initial parameters
// void _registerFactoryWithParams<T extends Object, P1, P2>(FactoryFuncParam<T, P1, P2> factoryFunc) =>
//     _getIt.registerFactoryParam<T, P1, P2>(factoryFunc);

/// The order matters when initializing the dependencies!
Future<void> setupDependencies() async {
  // Initialize Logging Configuration
  _initializeLogSystem();

  // Firebase Services (Storage, Auth, etc)
  await _registerFirebaseModule();

  // Shared Preferences
  await _registerSharedPreferencesModule();

  // Core Dependencies
  // await _registerCoreModule();

  // API Services Dependencies
  _registerApiModule();

  // Repositories Dependencies
  _registerRepositoriesModule();

  // Managers Dependencies
  // await _registerManagersModule();

  // Blocs
  _registerBlocsModule();

  // Use Cases
  _registerUseCasesModule();
}