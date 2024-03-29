import 'package:hypha_wallet/core/error_handler/model/hypha_error.dart';
import 'package:hypha_wallet/core/network/api/aws_amplify/amplify_service.dart';
import 'package:hypha_wallet/core/network/models/user_profile_data.dart';
import 'package:hypha_wallet/ui/architecture/result/result.dart';

class InitializeProfileUseCase {
  final AmplifyService _amplifyService;

  InitializeProfileUseCase(this._amplifyService);

  Future<Result<bool, HyphaError>> run({required UserProfileData user, required String name}) async {
    try {
      if (_amplifyService.isConnected()) {
        final credentials = await _amplifyService.getCredentials(user.network);
        // ignore: unused_local_variable
        final res = await _amplifyService.initializeProfile(
          name: name,
          s3Identity: credentials.userIdentityId!,
          network: user.network,
        );
        return Result.value(true);
      } else {
        return Result.error(HyphaError.api('User must be logged in.'));
      }
    } catch (error) {
      print('ProfileLoginUseCase error $error');
      print(error);
      return Result.error(HyphaError.api('ProfileLoginUseCase error $error'));
    }
  }
}
