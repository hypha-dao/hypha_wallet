import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypha_wallet/design/background/hypha_page_background.dart';
import 'package:hypha_wallet/design/buttons/hypha_app_button.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';
import 'package:hypha_wallet/design/secret_phrase/hypha_secret_phrase.dart';
import 'package:hypha_wallet/design/themes/extensions/theme_extension_provider.dart';
import 'package:hypha_wallet/ui/onboarding/components/onboarding_appbar.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/components/user_account_list.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/interactor/import_account_bloc.dart';

class ImportAccountView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportAccountBloc, ImportAccountState>(
      builder: (context, state) {
        return HyphaPageBackground(
          child: Scaffold(
            backgroundColor: HyphaColors.transparent,
            appBar: OnboardingAppbar(title: 'Use your', subTitle: ' 12 Secret words'),
            bottomNavigationBar: HyphaAppButton(
              margin: EdgeInsets.only(left: 45, right: 45, bottom: 45, top: 16),
              isLoading: state.isPartialLoading,
              onPressed: state.areAllWordsEntered
                  ? () {
                      context.read<ImportAccountBloc>().add(ImportAccountEvent.onActionButtonTapped(true));
                    }
                  : null,
              title: 'Find Account',
              isActive: state.areAllWordsEntered,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        'Enter your secret phrase to import your Hypha Account',
                        style: context.hyphaTextTheme.regular.copyWith(color: HyphaColors.primaryBlu),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16),
                    HyphaSecretPhrase(
                      words: state.userEnteredWords,
                      onSelected: (value) {
                        context.read<ImportAccountBloc>().add(ImportAccountEvent.onWordChanged(value.value, value.key));
                      },
                      onChanged: (value) {
                        context.read<ImportAccountBloc>().add(ImportAccountEvent.onWordChanged(value.value, value.key));
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ImportAccountBloc>().add(ImportAccountEvent.onUserPastedWords());
                      },
                      child: Text('Paste Words', style: context.hyphaTextTheme.buttons),
                    ),
                    UserAccountList(
                      accounts: state.accounts,
                      onTap: (data) {
                        context.read<ImportAccountBloc>().add(ImportAccountEvent.onAccountSelected(data));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
