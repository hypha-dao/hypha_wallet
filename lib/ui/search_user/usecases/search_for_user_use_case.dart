// import 'package:async/async.dart';
// import 'package:hypha_wallet/core/network/repository/user_account_repository.dart';
// import 'package:seeds/datasource/remote/api/members_repository.dart';
// import 'package:seeds/datasource/remote/model/profile_model.dart';
//
// class SearchForMemberUseCase {
//   final UserAccountRepository userAccountRepository;
//
//   Future<List<Result<List<ProfileModel>>>> run(String searchQuery) {
//     final futures = [
//       MembersRepository().getMembersWithFilter(searchQuery),
//       MembersRepository().getTelosAccounts(searchQuery),
//       MembersRepository().getFullNameSearchMembers(searchQuery),
//     ];
//     return Future.wait(futures);
//   }
// }
