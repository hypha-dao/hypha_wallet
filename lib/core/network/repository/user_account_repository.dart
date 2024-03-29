import 'package:hypha_wallet/core/error_handler/model/hypha_error.dart';
import 'package:hypha_wallet/core/network/api/services/hypha_member_service.dart';
import 'package:hypha_wallet/core/network/api/services/user_account_service.dart';
import 'package:hypha_wallet/core/network/models/network.dart';
import 'package:hypha_wallet/ui/architecture/result/result.dart';

class UserAccountRepository {
  final UserAccountService _userService;
  final HyphaMemberService _memberService;

  UserAccountRepository({required UserAccountService userService, required HyphaMemberService memberService})
      : _userService = userService,
        _memberService = memberService;

  Future<bool> isUserAccountAvailable(String accountName, Network network) async {
    return _userService.isUserAccountAvailable(accountName, network);
  }

  Future<String> findAvailableUserAccount(String fullName, Network network) async {
    return _userService.findAvailableUserAccount(fullName, network);
  }

  Future<Result<List<String>, HyphaError>> findHyphaAccounts(String prefix, Network network) {
    return _memberService.findHyphaAccounts(prefix: prefix, network: network);
  }
}
