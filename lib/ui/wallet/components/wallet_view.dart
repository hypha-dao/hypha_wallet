import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypha_wallet/core/network/models/transaction_model.dart';
import 'package:hypha_wallet/design/avatar_image/hypha_avatar_image.dart';
import 'package:hypha_wallet/design/background/hypha_page_background.dart';
import 'package:hypha_wallet/design/hypha_card.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';
import 'package:hypha_wallet/design/themes/extensions/theme_extension_provider.dart';
import 'package:hypha_wallet/ui/blocs/authentication/authentication_bloc.dart';
import 'package:hypha_wallet/ui/history/details/transaction_detail_page.dart';
import 'package:hypha_wallet/ui/shared/hypha_body_widget.dart';
import 'package:get/get.dart' as GetX;
import 'package:hypha_wallet/ui/shared/hypha_error_view.dart';
import 'package:hypha_wallet/ui/shared/listview_with_all_separators.dart';
import 'package:hypha_wallet/ui/sign_transaction/interactor/data/transaction_action_data.dart';
import 'package:hypha_wallet/ui/wallet/components/wallet_token_widget.dart';
import 'package:hypha_wallet/ui/wallet/components/wallet_transaction_tile.dart';
import 'package:hypha_wallet/ui/wallet/interactor/wallet_bloc.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return HyphaPageBackground(
      withOpacity: false,
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<WalletBloc>().add(const WalletEvent.onRefresh());
            },
            child: HyphaBodyWidget(
              pageState: state.pageState,
              failure: (_) {
                return HyphaErrorWidget(onRefreshPressed: () {
                  context.read<WalletBloc>().add(const WalletEvent.onRefresh());
                });
              },
              success: (value) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: Row(
                    children: [
                      BlocBuilder<AuthenticationBloc, AuthenticationState>(
                        builder: (context, state) {
                          return HyphaAvatarImage(
                            imageRadius: 17,
                            imageFromUrl: state.userProfileData?.userImage,
                            name: state.userProfileData?.userName,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text('Wallet', style: context.hyphaTextTheme.bigTitles),
                    ],
                  ),
                  titleSpacing: 28,
                ),
                backgroundColor: HyphaColors.transparent,
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150,
                      child: ListViewWithAllSeparators(
                        scrollDirection: Axis.horizontal,
                        items: state.tokens,
                        physics: const ClampingScrollPhysics(),
                        cacheExtent: MediaQuery.of(context).size.height * 2,
                        separatorBuilder: (_, int index) {
                          if (state.tokens.isEmpty) return const SizedBox.shrink();
                          if (index == 0) return const SizedBox(width: 28);
                          return const SizedBox(width: 16);
                        },
                        itemBuilder: (_, item, __) {
                          return WalletTokenWidget(token: item);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? HyphaColors.lightBlack : HyphaColors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          boxShadow:
                              context.isDarkMode ? HyphaColors.darkModeCardShadow : HyphaColors.lightModeCardShadow,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final TransactionModel item = state.recentTransactions[index];
                            return WalletTransactionTile(
                              data: TransactionDetailsCardData(
                                contractAction: item.actionName,
                                params: item.data,
                                timestamp: item.timestamp,
                                memo: item.data['memo'],
                                onTap: () {
                                  GetX.Get.to(
                                    TransactionDetailsPage(transactionModel: item),
                                    transition: GetX.Transition.rightToLeft,
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: 16);
                          },
                          itemCount: state.recentTransactions.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}