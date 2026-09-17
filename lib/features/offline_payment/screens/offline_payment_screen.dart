import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/sigma_responsive_content.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/shipping_details_widget.dart';
import 'package:provider/provider.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final double payableAmount;
  final Function callback;

  const OfflinePaymentScreen({
    super.key,
    required this.payableAmount,
    required this.callback,
  });

  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  TextEditingController paymentController = TextEditingController();
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderIdentifierController =
      TextEditingController();
  final GlobalKey<FormState> offlineFormKey = GlobalKey<FormState>();
  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('transfer_payment', context)),
      body: SigmaResponsiveContent(
        child: Consumer<CheckoutController>(
            builder: (context, checkoutProvider, _) {
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.homePagePadding),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: .2)),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(
                                      checkoutProvider
                                                  .selectedTransferChannel ==
                                              'instapay'
                                          ? Icons.account_balance_rounded
                                          : Icons
                                              .account_balance_wallet_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      getTranslated(
                                            checkoutProvider
                                                        .selectedTransferChannel ==
                                                    'instapay'
                                                ? 'instapay_payment'
                                                : 'electronic_wallet_payment',
                                            context,
                                          ) ??
                                          '',
                                      style: textBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge),
                                    ),
                                  ]),
                                  const SizedBox(height: 10),
                                  Text(
                                      getTranslated(
                                              'transfer_using_admin_details',
                                              context) ??
                                          '',
                                      style: textRegular),
                                  const SizedBox(height: 10),
                                  for (final field in checkoutProvider
                                          .offlinePaymentModel!
                                          .offlineMethods![checkoutProvider
                                              .offlineMethodSelectedIndex]
                                          .methodFields ??
                                      const <MethodFields>[])
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: SelectableText(
                                          '${field.inputName ?? ''}: ${field.inputData ?? ''}',
                                          style: textMedium),
                                    ),
                                ]),
                          ),
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  child: Text(
                                      '${getTranslated('amount', context)} : ${PriceConverter.convertPrice(context, widget.payableAmount)}',
                                      style: textBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeLarge)))),
                          Text(
                            '${getTranslated('payment_info', context)}',
                            style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge),
                          ),
                          Form(
                            key: offlineFormKey,
                            child: RepaintBoundary(
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: checkoutProvider
                                          .offlinePaymentModel!
                                          .offlineMethods![checkoutProvider
                                              .offlineMethodSelectedIndex]
                                          .methodInformations
                                          ?.length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    MethodInformations? methodInformation =
                                        checkoutProvider
                                            .offlinePaymentModel!
                                            .offlineMethods![checkoutProvider
                                                .offlineMethodSelectedIndex]
                                            .methodInformations?[index];

                                    // إذا كان نوع الحقل القادم من الأدمن image يتم رسم زر اختيار صورة بدلاً من الـ TextField
                                    if (methodInformation?.inputType ==
                                        'image') {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeDefault),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${getTranslated(methodInformation?.customerInput ?? '', context) ?? methodInformation?.customerPlaceholder ?? ''}${methodInformation?.isRequired == 1 ? ' *' : ''}',
                                              style: textBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault),
                                            ),
                                            const SizedBox(height: 10),
                                            InkWell(
                                              onTap: () async {
                                                final ImagePicker picker =
                                                    ImagePicker();
                                                final XFile? image =
                                                    await picker.pickImage(
                                                        source:
                                                            ImageSource.gallery,
                                                        imageQuality: 75);

                                                if (image != null) {
                                                  final file = File(image.path);
                                                  final extension = image.path
                                                      .split('.')
                                                      .last
                                                      .toLowerCase();
                                                  final validType = const [
                                                    'jpg',
                                                    'jpeg',
                                                    'png',
                                                    'webp'
                                                  ].contains(extension);
                                                  final validSize =
                                                      await file.length() <=
                                                          5 * 1024 * 1024;
                                                  if (!validType ||
                                                      !validSize) {
                                                    if (!context.mounted)
                                                      return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(getTranslated(
                                                              validType
                                                                  ? 'wallet_proof_too_large'
                                                                  : 'wallet_proof_invalid_type',
                                                              context) ??
                                                          (validType
                                                              ? 'Maximum image size is 5 MB'
                                                              : 'Use JPG, PNG or WEBP image')),
                                                    ));
                                                    return;
                                                  }
                                                  setState(() {
                                                    _pickedImage = file;
                                                  });
                                                  // نقوم بحفظ مسار الصورة داخل حقل الكنترولر التابع لهذا الـ index لتسهيل قراءته في الـ Controller
                                                  checkoutProvider
                                                      .inputFieldControllerList[
                                                          index]
                                                      .text = image.path;
                                                }
                                              },
                                              child: Container(
                                                height: 140,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius: BorderRadius
                                                      .circular(Dimensions
                                                          .paddingSizeSmall),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .hintColor
                                                          .withOpacity(0.5)),
                                                ),
                                                child: _pickedImage != null
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .paddingSizeSmall),
                                                        child: Image.file(
                                                            _pickedImage!,
                                                            fit: BoxFit.cover),
                                                      )
                                                    : Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.camera_alt,
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                              size: 40),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            getTranslated(
                                                                    'wallet_upload_proof',
                                                                    context) ??
                                                                '',
                                                            style: textRegular.copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                            // حقل خفي للتحقق من أن المستخدم قام برفع الصورة إذا كانت مطلوبة (is_required = 1)
                                            FormField<String>(
                                              validator: (value) {
                                                if (methodInformation
                                                            ?.isRequired ==
                                                        1 &&
                                                    _pickedImage == null) {
                                                  return getTranslated(
                                                      'wallet_proof_required',
                                                      context);
                                                }
                                                return null;
                                              },
                                              builder: (FormFieldState<String>
                                                  state) {
                                                return state.hasError
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                left: 5),
                                                        child: Text(
                                                            state.errorText!,
                                                            style: textRegular
                                                                .copyWith(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall)),
                                                      )
                                                    : const SizedBox();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // الحقول النصية العادية ترسم TextField كما كانت سابقاً
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeDefault),
                                      child: CustomTextFieldWidget(
                                        controller: checkoutProvider
                                            .inputFieldControllerList[index],
                                        required:
                                            methodInformation?.isRequired == 1,
                                        labelText: getTranslated(
                                                methodInformation
                                                        ?.customerInput ??
                                                    '',
                                                context) ??
                                            '${methodInformation?.customerPlaceholder}',
                                        hintText:
                                            '${methodInformation?.customerPlaceholder}'
                                                .replaceAll('_', ' ')
                                                .capitalize(),
                                        validator: (value) {
                                          if (methodInformation?.isRequired ==
                                              1) {
                                            return ValidateCheck.validateEmptyText(
                                                value,
                                                '${methodInformation?.customerInput}'
                                                    .replaceAll('_', ' ')
                                                    .capitalize());
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          const SizedBox(height: 14),
                          CustomTextFieldWidget(
                            controller: senderNameController,
                            required: true,
                            labelText: 'الاسم الثلاثي للمحوّل',
                            hintText: 'اكتب الاسم كما ظهر في عملية التحويل',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.name,
                            validator: (value) =>
                                ValidateCheck.validateEmptyText(
                                    value, 'sender_name_is_required'),
                          ),
                          const SizedBox(height: 14),
                          CustomTextFieldWidget(
                            controller: senderIdentifierController,
                            required: true,
                            labelText:
                                checkoutProvider.selectedTransferChannel ==
                                        'instapay'
                                    ? 'رقم الهاتف أو معرّف إنستا باي'
                                    : 'رقم المحفظة التي تم التحويل منها',
                            hintText:
                                checkoutProvider.selectedTransferChannel ==
                                        'instapay'
                                    ? 'مثال: name@instapay أو رقم الهاتف'
                                    : 'رقم المحفظة الإلكترونية',
                            inputAction: TextInputAction.next,
                            inputType: TextInputType.text,
                            validator: (value) =>
                                ValidateCheck.validateEmptyText(
                                    value, 'sender_identifier_is_required'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomTextFieldWidget(
                            controller: paymentController,
                            labelText: getTranslated('note', context),
                            hintText: getTranslated('note', context),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ])))
          ]);
        }),
      ),
      bottomNavigationBar:
          Consumer<CheckoutController>(builder: (context, checkoutProvider, _) {
        return Consumer<ProfileController>(
            builder: (context, profileProvider, _) {
          return Consumer<CouponController>(
              builder: (context, couponProvider, _) {
            return Consumer<AddressController>(
                builder: (context, locationProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  isLoading: checkoutProvider.isLoading,
                  onTap: () {
                    if (senderNameController.text.trim().isEmpty ||
                        senderIdentifierController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'يرجى إدخال اسم المحوّل والرقم أو المعرّف المستخدم في التحويل.'),
                        ),
                      );
                      return;
                    }
                    if (offlineFormKey.currentState?.validate() ?? false) {
                      String paymentNote = paymentController.text.trim();
                      String orderNote =
                          checkoutProvider.orderNoteController.text.trim();
                      String couponCode = couponProvider.discount != null &&
                              couponProvider.discount != 0
                          ? couponProvider.couponCode
                          : '';
                      String couponCodeAmount =
                          couponProvider.discount != null &&
                                  couponProvider.discount != 0
                              ? couponProvider.discount.toString()
                              : '0';
                      String addressId = checkoutProvider.addressIndex != null
                          ? locationProvider
                              .addressList![checkoutProvider.addressIndex!].id
                              .toString()
                          : '';

                      const String billingAddressId = '';

                      checkoutProvider.placeOrder(
                        callback: widget.callback,
                        paymentNote: paymentNote,
                        addressID: addressId,
                        billingAddressId: billingAddressId,
                        orderNote: orderNote,
                        couponCode: couponCode,
                        couponAmount: couponCodeAmount,
                        senderName: senderNameController.text.trim(),
                        senderIdentifier:
                            senderIdentifierController.text.trim(),
                        isfOffline: true,
                      );
                    }
                  },
                  buttonText: getTranslated('proceed', context),
                ),
              );
            });
          });
        });
      }),
    );
  }
}
