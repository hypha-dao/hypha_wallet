import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as Get;
import 'package:hypha_wallet/core/extension/scope_functions.dart';
import 'package:hypha_wallet/design/avatar_image/hypha_avatar_image.dart';
import 'package:hypha_wallet/design/background/hypha_page_background.dart';
import 'package:hypha_wallet/design/bottom_component/hypha_safe_bottom_navigation_bar.dart';
import 'package:hypha_wallet/design/buttons/hypha_app_button.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';
import 'package:hypha_wallet/design/themes/extensions/theme_extension_provider.dart';
import 'package:hypha_wallet/ui/blocs/deeplink/deeplink_bloc.dart';
import 'package:hypha_wallet/ui/onboarding/components/onboarding_appbar.dart';
import 'package:hypha_wallet/ui/onboarding/create_account/interactor/create_account_bloc.dart';
import 'package:hypha_wallet/ui/onboarding/edit_account/edit_account_page.dart';
import 'package:hypha_wallet/ui/shared/hypha_body_widget.dart';

class CreateAccountView extends StatelessWidget {
  const CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAccountBloc, CreateAccountState>(
      builder: (context, state) {
        return HyphaPageBackground(
          child: Scaffold(
            backgroundColor: HyphaColors.transparent,
            appBar: const OnboardingAppbar(title: 'Create your', subTitle: 'Hypha Account'),
            bottomNavigationBar: HyphaSafeBottomNavigationBar(
              child: HyphaAppButton(
                onPressed: () {
                  context
                      .read<DeeplinkBloc>()
                      .state
                      .inviteLinkData
                      ?.let((it) => context.read<CreateAccountBloc>().add(CreateAccountEvent.onNextTapped(it)));
                },
                title: 'NEXT',
              ),
            ),
            body: HyphaBodyWidget(
              success: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    HyphaAvatarImage(imageFromFile: state.image?.path, imageRadius: 34, name: state.userName),
                    const SizedBox(height: 14),
                    Text(state.userName, style: context.hyphaTextTheme.smallTitles),
                    const SizedBox(height: 70),
                    GestureDetector(
                      onTap: () {
                        _navigate(state);
                      },
                      child: TextFormField(
                        key: Key(state.userAccount ?? ''),
                        autofocus: false,
                        enabled: false,
                        onTap: () {
                          _navigate(state);
                        },
                        initialValue: state.userAccount,
                        decoration: InputDecoration(
                          labelText: 'Blockchain Account',
                          labelStyle: context.textTheme.labelLarge?.copyWith(color: HyphaColors.primaryBlu),
                          disabledBorder:
                              const UnderlineInputBorder(borderSide: BorderSide(color: HyphaColors.primaryBlu)),
                          enabledBorder:
                              const UnderlineInputBorder(borderSide: BorderSide(color: HyphaColors.primaryBlu)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'We automatically created a blockchain account for you. Click the Next button to finish. If you want a custom blockchain name you can create your own. Just click the field and enter the name of your choice.',
                      style: context.hyphaTextTheme.ralMediumBody.copyWith(color: HyphaColors.midGrey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              pageState: state.pageState,
            ),
          ),
        );
      },
    );
  }

  void _navigate(CreateAccountState state) {
    Get.Get.to(
      () => EditAccountPage(PageParams(
        file: state.image,
        name: state.userName,
      )),
      transition: Get.Transition.rightToLeft,
    );
  }
}
