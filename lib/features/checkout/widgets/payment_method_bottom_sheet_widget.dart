import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Purchase balance, online payment and offline transfer share checkout consent.
class PaymentMethodBottomSheetWidget extends StatelessWidget {
  final bool onlyDigital;
  const PaymentMethodBottomSheetWidget({super.key, required this.onlyDigital});

  @override
  Widget build(BuildContext context) {
    final configModel =
        Provider.of<SplashController>(context, listen: false).configModel;

    return Consumer<CheckoutController>(
      builder: (context, checkoutController, _) {
        final hasPurchaseBalance = configModel?.walletStatus == 1 &&
            Provider.of<AuthController>(context, listen: false).isLoggedIn();
        final hasOffline = !onlyDigital &&
            configModel?.offlinePayment != null &&
            (checkoutController
                    .offlinePaymentModel?.offlineMethods?.isNotEmpty ??
                false);
        final methods =
            checkoutController.offlinePaymentModel?.offlineMethods ?? [];
        final walletIndex = hasOffline ? _channelIndex(methods, 'wallet') : -1;
        final instaPayIndex =
            hasOffline ? _channelIndex(methods, 'instapay') : -1;
        final hasAnyMethod =
            hasPurchaseBalance || walletIndex >= 0 || instaPayIndex >= 0;

        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .7),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(children: [
                Text(getTranslated('choose_payment_method', context) ?? '',
                    style: titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                    child: Text(
                        getTranslated(
                                'click_one_of_the_option_below', context) ??
                            '',
                        style: textRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall))),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Expanded(
                child: hasAnyMethod
                    ? SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasPurchaseBalance)
                                _PaymentOptionTile(
                                  icon: Icons.account_balance_wallet_outlined,
                                  title: getTranslated(
                                          'purchase_wallet', context) ??
                                      '',
                                  subtitle: getTranslated(
                                          'purchase_wallet_only_notice',
                                          context) ??
                                      '',
                                  selected: checkoutController.isWalletChecked,
                                  onTap:
                                      checkoutController.selectPurchaseWallet,
                                ),
                              if (hasPurchaseBalance &&
                                  (walletIndex >= 0 || instaPayIndex >= 0))
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                              if (walletIndex >= 0)
                                _PaymentOptionTile(
                                  icon: Icons.phone_android_rounded,
                                  title: getTranslated(
                                          'electronic_wallet_payment',
                                          context) ??
                                      '',
                                  subtitle: getTranslated(
                                          'transfer_form_after_selection',
                                          context) ??
                                      '',
                                  selected:
                                      checkoutController.isOfflineChecked &&
                                          checkoutController
                                                  .selectedTransferChannel ==
                                              'wallet',
                                  onTap: () => checkoutController
                                      .selectOfflineTransferChannel(
                                          'wallet', walletIndex),
                                ),
                              if (walletIndex >= 0 && instaPayIndex >= 0)
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                              if (instaPayIndex >= 0)
                                _PaymentOptionTile(
                                  icon: Icons.account_balance_rounded,
                                  title: getTranslated(
                                          'instapay_payment', context) ??
                                      '',
                                  subtitle: getTranslated(
                                          'transfer_form_after_selection',
                                          context) ??
                                      '',
                                  selected:
                                      checkoutController.isOfflineChecked &&
                                          checkoutController
                                                  .selectedTransferChannel ==
                                              'instapay',
                                  onTap: () => checkoutController
                                      .selectOfflineTransferChannel(
                                          'instapay', instaPayIndex),
                                ),
                            ]),
                      )
                    : const NoInternetOrDataScreenWidget(
                        isNoInternet: false,
                        message: 'no_payment_method_available_right_now'),
              ),
              CustomButton(
                  buttonText: getTranslated('save', context) ?? '',
                  onTap: () => Navigator.of(context).pop()),
            ],
          ),
        );
      },
    );
  }

  int _channelIndex(List<OfflineMethods> methods, String channel) {
    final needle = channel == 'instapay' ? 'insta' : 'wallet';
    final index = methods.indexWhere((method) {
      final name = (method.methodName ?? '').toLowerCase();
      return name.contains(needle) ||
          (channel == 'instapay' && name.contains('انستا')) ||
          (channel == 'wallet' && name.contains('محفظ'));
    });
    return index;
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentOptionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? Theme.of(context).primaryColor.withValues(alpha: .09)
            : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textBold),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: textRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall,
                      )),
                ],
              )),
              Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor),
            ]),
          ),
        ),
      );
}

bool isPrepaidMethodAvailable(ConfigModel? configModel,
    List<OfflineMethods>? offlineMethods, bool onlyDigital) {
  return !onlyDigital &&
      configModel?.offlinePayment != null &&
      (offlineMethods?.isNotEmpty ?? false);
}
