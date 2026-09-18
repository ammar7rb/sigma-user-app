import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/widgets/address_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/widgets/address_type_widget.dart';
import 'package:provider/provider.dart';

class SavedAddressListScreen extends StatefulWidget {
  final bool fromGuest;
  final bool fromCheckout;
  const SavedAddressListScreen(
      {super.key, this.fromGuest = false, this.fromCheckout = false});

  @override
  State<SavedAddressListScreen> createState() => _SavedAddressListScreenState();
}

class _SavedAddressListScreenState extends State<SavedAddressListScreen> {
  @override
  void initState() {
    Provider.of<AddressController>(context, listen: false).getAddressList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => RouterHelper.getAddNewAddressRoute(
                  isBilling: false, fromCheckout: widget.fromCheckout),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(
                  getTranslated('add_new_address', context) ?? 'إضافة عنوان'),
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17))),
            ),
          ),
        ),
      ),
      appBar: CustomAppBar(
          title: widget.fromGuest
              ? getTranslated('ADDRESS_LIST', context)
              : getTranslated('SHIPPING_ADDRESS_LIST', context)),
      body: SafeArea(child: Consumer<AddressController>(
        builder: (context, locationProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                locationProvider.addressList != null
                    ? locationProvider.addressList!.isNotEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: locationProvider.addressList?.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () async {
                                    final addressId =
                                        locationProvider.addressList![index].id;
                                    if (addressId == null ||
                                        !await Provider.of<ShippingController>(
                                                context,
                                                listen: false)
                                            .quoteForAddress(
                                                context, addressId)) {
                                      return;
                                    }
                                    if (!context.mounted) return;
                                    final selectedOption =
                                        await showModalBottomSheet<String>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (sheetContext) =>
                                          Consumer<ShippingController>(
                                        builder:
                                            (context, shippingController, _) =>
                                                SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeDefault),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(children: [
                                                    Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: .12),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14)),
                                                        child: Icon(
                                                            Icons
                                                                .local_shipping_outlined,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall),
                                                    Expanded(
                                                        child: Text(
                                                            'اختر طريقة الشحن',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700))),
                                                  ]),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                      'تم حساب السعر تلقائيًا حسب المحافظة والعنوان.',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor)),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeDefault),
                                                  ...shippingController
                                                      .quotedOptions
                                                      .map((option) {
                                                    final key =
                                                        '${option['key']}';
                                                    final isSigma =
                                                        key == 'sigma';
                                                    final price = double.tryParse(
                                                            '${option['shipping_cost']}') ??
                                                        0;
                                                    final minDays = option[
                                                            'minimum_business_days'] ??
                                                        '';
                                                    final maxDays = option[
                                                            'maximum_business_days'] ??
                                                        '';
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          bottom: Dimensions
                                                              .paddingSizeSmall),
                                                      child: OutlinedButton(
                                                        onPressed:
                                                            shippingController
                                                                    .isLoading
                                                                ? null
                                                                : () async {
                                                                    if (await shippingController.selectQuoteForAddress(
                                                                            context,
                                                                            addressId,
                                                                            key) &&
                                                                        sheetContext
                                                                            .mounted) {
                                                                      Navigator.pop(
                                                                          sheetContext,
                                                                          key);
                                                                    }
                                                                  },
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                  .paddingSizeDefault),
                                                          alignment: Alignment
                                                              .centerRight,
                                                          backgroundColor: isSigma
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          .08)
                                                              : Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                          side: BorderSide(
                                                              color: isSigma
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .dividerColor,
                                                              width: isSigma
                                                                  ? 1.5
                                                                  : 1),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18)),
                                                        ),
                                                        child: Row(children: [
                                                          Container(
                                                              width: 42,
                                                              height: 42,
                                                              decoration: BoxDecoration(
                                                                  color: isSigma
                                                                      ? Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                          .withValues(
                                                                              alpha:
                                                                                  .10),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              13)),
                                                              child: Icon(
                                                                  isSigma
                                                                      ? Icons
                                                                          .bolt_rounded
                                                                      : Icons
                                                                          .local_shipping_outlined,
                                                                  color: isSigma
                                                                      ? Colors
                                                                          .white
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor)),
                                                          const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeSmall),
                                                          Expanded(
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                Row(children: [
                                                                  Flexible(
                                                                      child: Text(
                                                                          isSigma
                                                                              ? 'شحن سيجما'
                                                                              : 'شحن عادي',
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold))),
                                                                  if (isSigma) ...[
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                3),
                                                                        decoration: BoxDecoration(
                                                                            color: Theme.of(context)
                                                                                .primaryColor,
                                                                            borderRadius: BorderRadius.circular(
                                                                                20)),
                                                                        child: const Text(
                                                                            'الأفضل',
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.w700))),
                                                                  ],
                                                                ]),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                    'يصل خلال $minDays - $maxDays يوم عمل',
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .hintColor)),
                                                              ])),
                                                          Text(
                                                              PriceConverter
                                                                  .convertPrice(
                                                                      context,
                                                                      price),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor)),
                                                        ]),
                                                      ),
                                                    );
                                                  }),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    );
                                    if (selectedOption == null ||
                                        !context.mounted) return;
                                    Provider.of<CheckoutController>(context,
                                            listen: false)
                                        .setAddressIndex(index);
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeDefault),
                                      child: Container(
                                          margin: const EdgeInsets.only(
                                              top: Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color:
                                                  Theme.of(context).cardColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: .045),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 6),
                                                )
                                              ],
                                              border: index ==
                                                      Provider.of<CheckoutController>(
                                                              context)
                                                          .addressIndex
                                                  ? Border.all(
                                                      width: 2,
                                                      color: Theme.of(context)
                                                          .primaryColor)
                                                  : null),
                                          child: AddressTypeWidget(
                                              address: locationProvider
                                                  .addressList?[index]))));
                            },
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 3),
                            child: Center(
                                child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeLarge),
                                    child: const NoInternetOrDataScreenWidget(
                                        isNoInternet: false,
                                        message: 'no_address_found',
                                        icon: Images.noAddress))))
                    : const AddressShimmerWidget(),
              ],
            ),
          );
        },
      )),
    );
  }
}
