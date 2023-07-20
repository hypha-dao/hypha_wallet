import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hypha_wallet/core/network/api/services/remote_config_service.dart';

part 'user_profile_data.freezed.dart';
part 'user_profile_data.g.dart';

@freezed
class UserProfileData with _$UserProfileData {
  const UserProfileData._();

  factory UserProfileData({
    required String accountName,
    required Network network,
    @Default(null) String? userImage,
    @Default(null) String? bio,
    @Default(null) String? userName,
  }) = _UserProfileData;

  factory UserProfileData.fromJson(Map<String, dynamic> json) => _$UserProfileDataFromJson(json);

  String get userNameOrAccount  => userName != null ? userName! : accountName;
}
