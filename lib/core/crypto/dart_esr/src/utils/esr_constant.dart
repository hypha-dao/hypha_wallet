// ignore_for_file: library_prefixes, non_constant_identifier_names, always_declare_return_types, constant_identifier_names

import 'dart:convert';

import 'package:hypha_wallet/core/crypto/dart_esr/src/models/authorization.dart';
import 'package:hypha_wallet/core/crypto/dart_esr/src/signing_request_abi.dart' as signing_request_abis;
import 'package:hypha_wallet/core/crypto/dart_esr/src/signing_request_abi_v3.dart' as signing_request_v3_abis;
import 'package:hypha_wallet/core/crypto/eosdart/eosdart.dart' as eosDart;

/// Note: Only append at the end to this list since ESR is using the index of the chains as alias
/// I don't think it's used much except for the first 2, EOS and TELOS, and in any case we don't
/// currently support any of the other EOSIO networks anyway - we don't have the network endpoints etc.
/// We only support EOS, TELOS, TELOS_TESTNET and EOS_JUNGLE4.
///
enum ChainName {
  RESERVED,
  EOS,
  TELOS,
  EOS_JUNGLE2,
  KYLIN,
  WORBLI,
  BOS,
  MEETONE,
  INSIGHTS,
  BEOS,
  WAX,
  PROTON,
  FIO,
  TELOS_TESTNET,
  EOS_JUNGLE4,
}

class ESRConstants {
  static const int ProtocolVersion = 2;
  static const int ProtocolVersion3 = 3;

  static eosDart.Abi signingRequestAbi(int version) => eosDart.Abi.fromJson(
        json.decode(
          version < 3 ? signing_request_abis.signingRequestAbi : signing_request_v3_abis.signingRequestAbiV3,
        ),
      );

  static Map<String?, eosDart.Type> signingRequestAbiType(int version) =>
      eosDart.getTypesFromAbi(eosDart.createInitialTypes(), signingRequestAbi(version));

  static const RequestFlagsNone = 0;
  static const RequestFlagsBroadcast = 1 << 0;
  static const RequestFlagsBackground = 1 << 1;

  static const Scheme = 'esr:';
  static const PlaceholderName = '............1'; // aka uint64(1)
  static const PlaceholderPermission = '............2'; // aka uint64(2)
  static Authorization PlaceholderAuth = Authorization()
    ..actor = PlaceholderName
    ..permission = PlaceholderPermission;

  // ignore: type_annotate_public_apis
  static getChainAlias(ChainName name) => name.index;

  static final Map<ChainName, String> ChainIdLookup = {
    ChainName.RESERVED: '0000000000000000000000000000000000000000000000000000000000000000',
    ChainName.EOS: 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
    ChainName.TELOS: '4667b205c6838ef70ff7988f6e8257e8be0e1284a2f59699054a018f743b1d11',
    ChainName.EOS_JUNGLE2: 'e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473',
    ChainName.KYLIN: '5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191',
    ChainName.WORBLI: '73647cde120091e0a4b85bced2f3cfdb3041e266cbbe95cee59b73235a1b3b6f',
    ChainName.BOS: 'd5a3d18fbb3c084e3b1f3fa98c21014b5f3db536cc15d08f9f6479517c6a3d86',
    ChainName.MEETONE: 'cfe6486a83bad4962f232d48003b1824ab5665c36778141034d75e57b956e422',
    ChainName.INSIGHTS: 'b042025541e25a472bffde2d62edd457b7e70cee943412b1ea0f044f88591664',
    ChainName.BEOS: 'b912d19a6abd2b1b05611ae5be473355d64d95aeff0c09bedc8c166cd6468fe4',
    ChainName.WAX: '1064487b3cd1a897ce03ae5b6a865651747e2e152090f99c1d19d44e01aea5a4',
    ChainName.PROTON: '384da888112027f0321850a169f737c33e53b388aad48b5adace4bab97f437e0',
    ChainName.FIO: '21dcae42c0182200e93f954a074011f9048a7624c6fe81d3c9541a614a88bd1c',
    ChainName.TELOS_TESTNET: '1eaa0824707c8c16bd25145493bf062aecddfeb56c736f6ba6397f3195f33c9f',
    ChainName.EOS_JUNGLE4: '73e4385a2708e6d7048834fbc1079f2fabb17b3c125b146af438971e90716c4d',
  };
}
