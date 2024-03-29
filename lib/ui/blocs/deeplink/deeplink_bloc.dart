import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hypha_wallet/core/crypto/dart_esr/dart_esr.dart';
import 'package:hypha_wallet/core/crypto/seeds_esr/scan_qr_code_result_data.dart';
import 'package:hypha_wallet/core/error_handler/error_handler_manager.dart';
import 'package:hypha_wallet/core/error_handler/model/hypha_error.dart';
import 'package:hypha_wallet/core/error_handler/model/hypha_error_type.dart';
import 'package:hypha_wallet/core/logging/log_helper.dart';
import 'package:hypha_wallet/core/network/models/network.dart';
import 'package:hypha_wallet/core/network/repository/auth_repository.dart';
import 'package:hypha_wallet/ui/home_page/usecases/parse_qr_code_use_case.dart';

part 'deeplink_bloc.freezed.dart';

part 'deeplink_event.dart';

part 'deeplink_state.dart';

part 'page_command.dart';

class DeeplinkBloc extends Bloc<DeeplinkEvent, DeeplinkState> {
  final ParseQRCodeUseCase _parseQRCodeUseCase;
  final AuthRepository _authRepository;
  final ErrorHandlerManager _errorHandlerManager;
  final _appLinks = AppLinks();

  late StreamSubscription<String> _linkSubscription;

  DeeplinkBloc(this._parseQRCodeUseCase, this._authRepository, this._errorHandlerManager)
      : super(const DeeplinkState()) {
    initDynamicLinks();

    on<_IncomingFirebaseDeepLink>(_incomingFirebaseDeepLink);
    on<_IncomingESRLink>(_incomingESRLink);
    on<_ClearPageCommand>((_, emit) => emit(state.copyWith(command: null)));
    on<_ClearInviteLink>((_, emit) => emit(state.copyWith(inviteLinkData: null)));
  }

  @override
  Future<void> close() {
    _linkSubscription.cancel();
    return super.close();
  }

  Future<void> initDynamicLinks() async {
    // Handle initial firebase links - such as post install
    final PendingDynamicLinkData? initialDeepLink = await FirebaseDynamicLinks.instance.getInitialLink();
    LogHelper.d('initDynamicLinks initialDeepLink: - $initialDeepLink');

    if (initialDeepLink != null) {
      LogHelper.d('initial deep link: ${initialDeepLink.link}');
      if (!initialDeepLink.link.isEsr()) {
        add(DeeplinkEvent.incomingFirebaseDeepLink(initialDeepLink.link));
      }
    }

    // Handle initial ESR links
    final initialUriString = await _appLinks.getInitialAppLinkString();
    if (initialUriString != null) {
      if (SigningRequestManager.isValidESRScheme(initialUriString)) {
        add(DeeplinkEvent.incomingESRLink(initialUriString));
      }
    }

    // Listen to ESR links
    _linkSubscription = _appLinks.stringLinkStream.listen((uriString) {
      // Note: We must listen to strings, not Uris; Uri parsing loses case
      // and ESR signing requests are case sensitive.
      if (SigningRequestManager.isValidESRScheme(uriString)) {
        LogHelper.d('esr link detected: $uriString');
        add(DeeplinkEvent.incomingESRLink(uriString));
      }
    }, onError: (error) {
      print('link subscription error $error');
    });

    // Listen to Firebase deep links
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData dynamicLinkData) {
      LogHelper.d('received deep link: ${dynamicLinkData.link}');

      if (!dynamicLinkData.link.isEsr()) {
        add(DeeplinkEvent.incomingFirebaseDeepLink(dynamicLinkData.link));
      }
    }).onError((error) {
      LogHelper.e('Deep link error: $error');
    });
  }

  Future<void> _incomingFirebaseDeepLink(_IncomingFirebaseDeepLink event, Emitter<DeeplinkState> emit) async {
    /// fetch data from link.
    final queryParams = event.link.queryParameters;
    if (queryParams.isNotEmpty && queryParams.containsKey('code') && queryParams.containsKey('chain')) {
      final code = queryParams['code']!;
      final chain = queryParams['chain']!;
      final network = Network.fromString(chain);
      final dao = queryParams['dao']!;
      final String? enrollSecret = queryParams['enroll_secret'];

      final inviteLinkData = InviteLinkData(
        code: code,
        network: network,
        dao: dao,
        enrollSecret: enrollSecret,
      );

      final PageCommand command;
      if (_authRepository.currentAuthStatus is Authenticated) {
        command = PageCommand.showJoinDaoRationale(inviteLinkData);
      } else {
        command = const PageCommand.navigateToCreateAccount();
      }

      /// Emit new state with data from link
      emit(
        state.copyWith(
          inviteLinkData: inviteLinkData,
          command: command,
        ),
      );
    }
  }

  Future<void> _incomingESRLink(_IncomingESRLink event, Emitter<DeeplinkState> emit) async {
    final result = await _parseQRCodeUseCase.run(ParseESRLinkInput(esrLink: event.link));
    if (result.isValue) {
      if (_canSignTransaction()) {
        emit(state.copyWith(command: PageCommand.navigateToSignTransaction(result.asValue!.value)));
      } else {
        unawaited(
          _errorHandlerManager.handlerError(
            HyphaError(
              message: 'No account found. Please import an account before continuing',
              type: HyphaErrorType.generic,
            ),
          ),
        );
      }
    } else {
      unawaited(
        _errorHandlerManager.handlerError(HyphaError(message: 'Error parsing Link', type: HyphaErrorType.generic)),
      );
      LogHelper.e('error: ${result.asError!.error}');
    }
  }

  /// At the time of writing this code.
  /// The only requirement for our wallet to be able to sign a VALID transaction
  /// is that there is an account to sign with
  bool _canSignTransaction() {
    return _authRepository.currentAuthStatus is Authenticated;
  }
}

extension UriESR on Uri {
  bool isEsr() {
    return SigningRequestManager.isValidESRScheme(toString());
  }
}
