import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hypha_wallet/design/cards/hypha_transaction_action_card.dart';
import 'package:hypha_wallet/design/countdown_timer/countdown_timer_text.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';
import 'package:hypha_wallet/design/slide_to/slide_to_confirm.dart';
import 'package:hypha_wallet/design/themes/extensions/theme_extension_provider.dart';
import 'package:hypha_wallet/ui/sign_transaction/interactor/sign_transaction_bloc.dart';

class SignTransactionView extends StatelessWidget {
  const SignTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignTransactionBloc, SignTransactionState>(
      builder: (context, state) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: context.isDarkTheme ? HyphaColors.gradientBlack : HyphaColors.gradientWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              _Header('Signing request', state.transactionDetailsData.signingTitle),
              if (state.transactionDetailsData.isFreeTransaction) ...[
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _FreeTransaction(),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ...state.transactionDetailsData.cards
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(22),
                              child: HyphaTransactionActionCard(data: e),
                            ),
                          )
                          .toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'This transaction expires in ',
                              style: context.hyphaTextTheme.ralMediumSmallNote.copyWith(color: HyphaColors.midGrey),
                            ),
                            CountDownText(
                              due: state.transactionDetailsData.expirationTime,
                              finishedText: 'Expired',
                              showLabel: true,
                              longDateName: false,
                              style: context.hyphaTextTheme.ralMediumSmallNote.copyWith(color: HyphaColors.midGrey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SafeArea(child: _Slider()),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _FreeTransaction extends StatelessWidget {
  const _FreeTransaction();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Free', style: context.hyphaTextTheme.smallTitles.copyWith(color: HyphaColors.success)),
            const SizedBox(width: 4),
            Text('Transaction', style: context.hyphaTextTheme.smallTitles),
          ],
        ),
        Text('Transaction will be covered by Hypha',
            style: context.hyphaTextTheme.ralMediumLabel.copyWith(
              color: HyphaColors.midGrey,
              fontStyle: FontStyle.italic,
            )),
      ],
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Builder(
        builder: (context) {
          final GlobalKey<SlideActionState> _key = GlobalKey();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SlideAction(
              outerColor: context.isDarkTheme ? HyphaColors.lightBlack : HyphaColors.white,
              key: _key,
              onSubmit: () {
                context.read<SignTransactionBloc>().add(const SignTransactionEvent.onUserSlideCompleted());
              },
              onCancel: () {
                context.read<SignTransactionBloc>().add(const SignTransactionEvent.onUserSlideCanceled());
              },
              alignment: Alignment.center,
              submittedIcon: const CircularProgressIndicator(),
              child: Text('Slide to Sign', style: context.hyphaTextTheme.ralMediumSmallNote),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      color: context.isDarkTheme ? HyphaColors.lightBlack : HyphaColors.white,
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.hyphaTextTheme.mediumTitles),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.hyphaTextTheme.regular.copyWith(color: HyphaColors.primaryBlu),
                ),
              ],
            ),
            SvgPicture.asset('assets/images/logos/hypha_logo.svg', height: 44, width: 44)
          ],
        ),
      ),
    );
  }
}
