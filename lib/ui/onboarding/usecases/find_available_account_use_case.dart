import 'package:hypha_wallet/core/error_handler/model/hypha_error.dart';
import 'package:hypha_wallet/core/network/repository/user_account_repository.dart';
import 'package:hypha_wallet/ui/architecture/interactor/base_usecase.dart';
import 'package:hypha_wallet/ui/architecture/result/result.dart';

class FindAvailableAccountUseCase extends InputUseCase<Result<String, HyphaError>, String> {
  final UserAccountRepository _userAccountRepository;

  FindAvailableAccountUseCase(this._userAccountRepository);

  @override
  Future<Result<String, HyphaError>> run(String input) async {
    try {
      final result = await _userAccountRepository.findAvailableUserAccount(input);
      return Result.value(result);
    } catch (e) {
      return Result.error(HyphaError.api('Error looking for available user account'));
    }
  }
}
