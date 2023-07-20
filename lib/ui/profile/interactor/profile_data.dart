import 'package:hypha_wallet/core/network/api/services/remote_config_service.dart';

class ProfileData {
  final String? avatarUrl;
  final String? name;
  final String account;
  final String? bio;
  final CryptoAccountData? bitCoinData;
  final CryptoAccountData? eosData;
  final String? s3Identity;
  final String? avatar;
  final bool? deleted;
  final Network network;

  ProfileData({
    required this.name,
    required this.account,
    this.avatarUrl,
    this.bio,
    this.bitCoinData,
    this.eosData,
    this.s3Identity,
    this.avatar,
    this.deleted,
    required this.network,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json, Network network) {
    final account = json['eosAccount'];
    final avatarUrl = json['avatarUrl'];
    final publicData = json['publicData'];
    final name = publicData['name'];
    final bio = publicData['bio'];
    final deleted = publicData['deleted'];
    return ProfileData(
      name: name,
      account: account,
      avatarUrl: avatarUrl,
      bio: bio,
      deleted: deleted,
      network: network,
    );
  }

  ProfileData updateBio(String? bio) => ProfileData(
        name: name,
        account: account,
        bio: bio,
        avatar: avatar,
        avatarUrl: avatarUrl,
        bitCoinData: bitCoinData,
        eosData: eosData,
        s3Identity: s3Identity,
        network: network,
      );

  ProfileData updateName(String? name) => ProfileData(
        name: name,
        account: account,
        bio: bio,
        avatar: avatar,
        avatarUrl: avatarUrl,
        bitCoinData: bitCoinData,
        eosData: eosData,
        s3Identity: s3Identity,
        network: network,
      );

  ProfileData updateImageAvatar(String avatar) => ProfileData(
        name: name,
        account: account,
        bio: bio,
        avatar: avatar,
        avatarUrl: avatar,
        bitCoinData: bitCoinData,
        eosData: eosData,
        s3Identity: s3Identity,
        network: network,
      );

  ProfileData removeAvatar() => ProfileData(
        name: name,
        account: account,
        bio: bio,
        avatar: null,
        avatarUrl: null,
        bitCoinData: bitCoinData,
        eosData: eosData,
        s3Identity: s3Identity,
        network: network,
      );
}

class CryptoAccountData {
  final String cryptoName;
  final String accountAddress;
  final String? accountName;
  final String imageUrl;
  final bool isSelected;

  CryptoAccountData({
    required this.accountAddress,
    this.accountName,
    required this.imageUrl,
    required this.cryptoName,
    required this.isSelected,
  });
}

class OrganizationData {
  final String name;
  final String? image;

  OrganizationData({required this.name, this.image});
}
