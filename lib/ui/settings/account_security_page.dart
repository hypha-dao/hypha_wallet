import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hypha_wallet/ui/blocs/authentication/authentication_bloc.dart';
import 'package:hypha_wallet/ui/settings/save_key_page.dart';
import 'package:hypha_wallet/ui/settings/save_words_page.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.userAuthData?.words.isNotEmpty == true) ...[
                ListTile(
                  onTap: () {
                    Get.to(() => SaveWordsPage(state.userAuthData!.words));
                  },
                  title: const Text('Save your 12 secret words'),
                  trailing: const Icon(Icons.navigate_next),
                )
              ],
              if (state.userAuthData?.eOSPrivateKey != null) ...[
                ListTile(
                  onTap: () {
                    Get.to(() => SaveKeyPage(state.userAuthData!.eOSPrivateKey.toString()));
                  },
                  title: const Text('Save your private key'),
                  trailing: const Icon(Icons.navigate_next),
                ),
              ]
            ],
          );
        },
      ),
    );
  }
}
