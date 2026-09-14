import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
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
        final hasOffline = !onlyDigital &&
            configModel?.offlinePayment != null &&
            (checkoutController
                    .offlinePaymentModel?.offlineMethods?.isNotEmpty ??
                false);

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
                child: hasOffline
                    ? SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _transferMethods(context, checkoutController),
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

  Widget _transferMethods(
      BuildContext context, CheckoutController checkoutController) {
    final methods = checkoutController.offlinePaymentModel!.offlineMethods!;
    final walletIndex = _channelIndex(methods, 'wallet');
    final instaPayIndex = _channelIndex(methods, 'instapay');
    return Container(
      decoration: BoxDecoration(
        color: checkoutController.isOfflineChecked
            ? Theme.of(context).primaryColor.withValues(alpha: .15)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getTranslated('transfer_payment', context) ?? '',
              style: textBold),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(
                child: _TransferTile(
              icon: Icons.account_balance_wallet_outlined,
              title: getTranslated('electronic_wallet_payment', context) ?? '',
              selected: checkoutController.isOfflineChecked &&
                  checkoutController.selectedTransferChannel == 'wallet',
              onTap: () => checkoutController.selectOfflineTransferChannel(
                  'wallet', walletIndex),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
                child: _TransferTile(
              icon: Icons.account_balance_rounded,
              title: getTranslated('instapay_payment', context) ?? '',
              selected: checkoutController.isOfflineChecked &&
                  checkoutController.selectedTransferChannel == 'instapay',
              onTap: () => checkoutController.selectOfflineTransferChannel(
                  'instapay', instaPayIndex),
            )),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(getTranslated('transfer_form_after_selection', context) ?? '',
              style: textRegular.copyWith(color: Theme.of(context).hintColor)),
        ]),
      ),
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
    if (index >= 0) return index;
    return channel == 'instapay' && methods.length > 1 ? 1 : 0;
  }
}

class _TransferTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _TransferTile(
      {required this.icon,
      required this.title,
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
            child: Column(children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: textBold),
              const SizedBox(height: 6),
              Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20),
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
