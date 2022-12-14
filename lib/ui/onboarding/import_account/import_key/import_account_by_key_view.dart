import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hypha_wallet/design/background/hypha_page_background.dart';
import 'package:hypha_wallet/design/buttons/hypha_app_button.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';
import 'package:hypha_wallet/design/themes/extensions/theme_extension_provider.dart';
import 'package:hypha_wallet/ui/onboarding/components/onboarding_appbar.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/components/user_account_list.dart';
import 'package:hypha_wallet/ui/onboarding/import_account/interactor/import_account_bloc.dart';

class ImportAccountByKeyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportAccountBloc, ImportAccountState>(
      builder: (context, state) {
        return HyphaPageBackground(
          child: Scaffold(
            backgroundColor: HyphaColors.transparent,
            appBar: OnboardingAppbar(title: 'Use your', subTitle: 'Private key'),
            bottomNavigationBar: HyphaAppButton(
              margin: EdgeInsets.only(left: 45, right: 45, bottom: 45, top: 16),
              isLoading: state.isPartialLoading,
              onPressed: state.isPrivateKeyValid
                  ? () {
                      context.read<ImportAccountBloc>().add(ImportAccountEvent.onActionButtonTapped(false));
                    }
                  : null,
              title: 'Find Account',
              isActive: state.isPrivateKeyValid,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Enter your private key to import your Hypha Account',
                      style: context.hyphaTextTheme.regular.copyWith(color: HyphaColors.primaryBlu),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 120),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Private Key',
                        labelStyle: context.textTheme.labelLarge?.copyWith(color: HyphaColors.midGrey),
                        disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HyphaColors.primaryBlu)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: HyphaColors.primaryBlu)),
                      ),
                      onChanged: (value) {
                        context.read<ImportAccountBloc>().add(ImportAccountEvent.onPrivateKeyChanged(value));
                      },
                    ),
                    SizedBox(height: 16),
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
