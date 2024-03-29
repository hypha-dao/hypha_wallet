part of 'di_setup.dart';

void _initializeLogSystem() {
  if (!kReleaseMode) {
    Fimber.plantTree(DebugTree(useColors: true));
  }
  // Log Errors to the Crash Reporting Systems
  if (kReleaseMode) {
    // Fimber.plantTree(SentryCrashReportingTree());
    Fimber.plantTree(FirebaseCrashReportingTree());
  }
}
