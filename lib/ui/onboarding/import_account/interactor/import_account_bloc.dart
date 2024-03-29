import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hypha_wallet/core/error_handler/error_handler_manager.dart';
import 'package:hypha_wallet/core/error_handler/model/hypha_error.dart';
import 'package:hypha_wallet/core/error_handler/model/hypha_error_type.dart';
import 'package:hypha_wallet/core/extension/scope_functions.dart';
import 'package:hypha_wallet/core/local/models/user_auth_data.dart';
import 'package:hypha_wallet/core/logging/log_helper.dart';
import 'package:hypha_wallet/core/network/models/user_profile_data.dart';
import 'package:hypha_wallet/core/network/repository/auth_repository.dart';
import 'package:hypha_wallet/ui/architecture/interactor/page_states.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/interactor/account_import_type.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/usecases/find_account_use_case.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/usecases/generate_key_from_recovery_words_use_case.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/usecases/validate_key_use_case.dart';

part 'import_account_bloc.freezed.dart';
part 'import_account_event.dart';
part 'import_account_state.dart';
part 'page_command.dart';

const int wordsMax = 12;

class ImportAccountBloc extends Bloc<ImportAccountEvent, ImportAccountState> {
  final AuthRepository _authRepository;
  final GenerateKeyFromRecoveryWordsUseCase _fromRecoveryWordsUseCase;
  final ValidateKeyUseCase _validateKeyUseCase;
  final ErrorHandlerManager _errorHandlerManager;
  final FindAccountsUseCase _findAccountsUseCase;

  Timer? _debounce;

  ImportAccountBloc(
    this._fromRecoveryWordsUseCase,
    this._validateKeyUseCase,
    this._errorHandlerManager,
    this._findAccountsUseCase,
    this._authRepository,
  ) : super(const ImportAccountState()) {
    on<_Initial>(_initial);
    on<_ClearPageCommand>((_, emit) => emit(state.copyWith(command: null)));
    on<_OnWordChange>(_onWordChange);
    on<_OnActionButtonTapped>(_onActionButtonTapped);
    on<_OnUserPastedWords>(_onUserPastedWords);
    on<_OnPrivateKeyChanged>(_onPrivateKeyChanged);
    on<_FindAccountByKey>(_findAccountByKey);
    on<_OnAccountSelected>(_onAccountSelected);
    on<_OnImportTypeChangeTapped>(_onImportTypeChangeTapped);
  }

  Future<String> _getClipboardData() async {
    final clipboardData = await Clipboard.getData('text/plain');
    return clipboardData?.text ?? '';
  }

  List<String> _formatPastedString(String clipData) => clipData
      .toLowerCase()
      .replaceAll(RegExp('[^a-z]'), ' ')
      .split(' ')
      .where((word) => word.trim().length > 1)
      .toList();

  void _error(String s) {
    _errorHandlerManager.handlerError(HyphaError(message: s, type: HyphaErrorType.generic));
  }

  Future<void> _onUserPastedWords(_OnUserPastedWords event, Emitter<ImportAccountState> emit) async {
    final clipData = await _getClipboardData();
    final List<String> words = _formatPastedString(clipData);
    // No data in the clipboard, just return
    if (words.isEmpty) {
      return;
    }
    if (words.length > 12) {
      _error('Too many words: ${words.length}. Please paste exactly 12 words.');
      return;
    }
    if (words.length < 12) {
      _error('Too few words: ${words.length}. Please paste exactly 12 words.');
      return;
    }

    final Map<int, String> wordsMap = Map.from(state.userEnteredWords);
    wordsMap.clear();

    // In case the user copied more than 12 words, we drop any word after 12
    final List<String> splitWords = words.sublist(0, words.length <= wordsMax ? words.length : wordsMax);
    var count = 0;
    for (final word in splitWords) {
      wordsMap.putIfAbsent(count++, () => word);
    }

    emit(state.copyWith(userEnteredWords: wordsMap));
    if (wordsMap.length == wordsMax) {
      add(const ImportAccountEvent.onActionButtonTapped(true));
    }
  }

  Future<void> _initial(_Initial event, Emitter<ImportAccountState> emit) async {
    emit(state.copyWith(pageState: PageState.success));
  }

  FutureOr<void> _onWordChange(_OnWordChange event, Emitter<ImportAccountState> emit) {
    final Map<int, String> enteredWords = Map.from(state.userEnteredWords);
    enteredWords[event.index] = event.word;
    emit(state.copyWith(userEnteredWords: enteredWords));

    if (enteredWords.length == wordsMax) {
      add(const ImportAccountEvent.onActionButtonTapped(true));
    }
  }

  FutureOr<void> _onActionButtonTapped(_OnActionButtonTapped event, Emitter<ImportAccountState> emit) async {
    if (event.findByWords) {
      final authData = await _fromRecoveryWordsUseCase.run(state.userEnteredWords.values.toList());
      final privateKey = authData.eOSPrivateKey.toString();
      add(ImportAccountEvent.findAccountByKey(privateKey));
    } else {
      state.accountKey?.let((it) => add(ImportAccountEvent.findAccountByKey(it)));
    }
  }

  FutureOr<void> _onPrivateKeyChanged(_OnPrivateKeyChanged event, Emitter<ImportAccountState> emit) {
    emit(state.copyWith(accountKey: event.privateKey));
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      add(ImportAccountEvent.findAccountByKey(event.privateKey));
    });
  }

  FutureOr<void> _findAccountByKey(_FindAccountByKey event, Emitter<ImportAccountState> emit) async {
    emit(state.copyWith(isPartialLoading: true));
    final String? publicKey = await _validateKeyUseCase.run(event.privateKey);
    emit(state.copyWith(isPrivateKeyValid: true));

    if (publicKey == null || publicKey.isEmpty) {
      // ignore: unawaited_futures
      _errorHandlerManager.handlerError(HyphaError(message: 'Invalid Key', type: HyphaErrorType.generic));
      emit(state.copyWith(isPartialLoading: false, isPrivateKeyValid: false));
    } else {
      final results = await _findAccountsUseCase.run(publicKey);

      if (results.isValue) {
        final Iterable<UserProfileData> accounts = results.asValue!.value;
        if (accounts.isEmpty) {
          // _errorHandlerManager.handlerError(HyphaError(message: 'No Accounts Found', type: HyphaErrorType.generic));
          emit(state.copyWith(showNoAccountsFound: true));
        } else {
          emit(state.copyWith(accountKey: event.privateKey, showNoAccountsFound: false));
        }

        emit(state.copyWith(isPartialLoading: false, accounts: accounts.toList()));
      } else {
        LogHelper.d(results.asError!.error.toString());
        // ignore: unawaited_futures
        _errorHandlerManager.handlerError(HyphaError(message: 'Error Loading accounts', type: HyphaErrorType.generic));
        emit(state.copyWith(isPartialLoading: false));
      }
    }
  }

  FutureOr<void> _onAccountSelected(_OnAccountSelected event, Emitter<ImportAccountState> emit) {
    _authRepository.login(
      event.accountData,
      UserAuthData.fromKeyAndWords(
        state.accountKey!,
        state.areAllWordsEntered ? state.userEnteredWords.values.toList() : [],
      ),
      true,
    );
  }

  FutureOr<void> _onImportTypeChangeTapped(_OnImportTypeChangeTapped event, Emitter<ImportAccountState> emit) {
    emit(
      state.copyWith(
        accountImportType:
            state.accountImportType == AccountImportType.words ? AccountImportType.key : AccountImportType.words,
      ),
    );
  }
}
