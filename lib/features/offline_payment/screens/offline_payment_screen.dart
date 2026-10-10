import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/sigma_responsive_content.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/transfer_recipient_card.dart';
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

  int _senderIdentifierIndex(CheckoutController checkout) =>
      checkout.keyList.indexWhere((key) =>
          key == 'sender_wallet_or_phone' || key == 'sender_identifier');

  String _senderName(CheckoutController checkout) {
    final index = checkout.keyList.indexOf('sender_name');
    return (index >= 0
            ? checkout.inputFieldControllerList[index].text
            : senderNameController.text)
        .trim();
  }

  String _senderIdentifier(CheckoutController checkout) {
    final index = _senderIdentifierIndex(checkout);
    return (index >= 0
            ? checkout.inputFieldControllerList[index].text
            : senderIdentifierController.text)
        .trim();
  }

  Future<void> _pickPaymentProof(BuildContext context,
      CheckoutController checkout, int? fieldIndex) async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image == null) return;
    final file = File(image.path);
    final extension = image.path.split('.').last.toLowerCase();
    final validType = const ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
    final validSize = await file.length() <= 5 * 1024 * 1024;
    if (!mounted || !context.mounted) return;
    if (!validType || !validSize) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(getTranslated(
                validType
                    ? 'wallet_proof_too_large'
                    : 'wallet_proof_invalid_type',
                context) ??
            ''),
      ));
      return;
    }
    setState(() => _pickedImage = file);
    if (fieldIndex != null &&
        fieldIndex < checkout.inputFieldControllerList.length) {
      checkout.inputFieldControllerList[fieldIndex].text = image.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('transfer_payment', context)),
      body: SigmaResponsiveContent(
        child: Consumer<CheckoutController>(
            builder: (context, checkoutProvider, _) {
          final selectedMethod = checkoutProvider.offlinePaymentModel!
              .offlineMethods![checkoutProvider.offlineMethodSelectedIndex];
          final configuredInputs =
              selectedMethod.methodInformations ?? const <MethodInformations>[];
          final hasProofField =
              configuredInputs.any((field) => field.inputType == 'image');
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.homePagePadding),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TransferRecipientCard(
                            channel: checkoutProvider.selectedTransferChannel,
                            details: [
                              for (final field in checkoutProvider
                                      .offlinePaymentModel!
                                      .offlineMethods![checkoutProvider
                                          .offlineMethodSelectedIndex]
                                      .methodFields ??
                                  const <MethodFields>[])
                                TransferRecipientDetail(field.inputName ?? '',
                                    field.inputData ?? ''),
                            ],
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
                                  itemCount: configuredInputs.length +
                                      (hasProofField ? 0 : 1),
                                  itemBuilder: (context, index) {
                                    if (index == configuredInputs.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                getTranslated(
                                                        'payment_screenshot',
                                                        context) ??
                                                    '',
                                                style: textBold),
                                            const SizedBox(height: 8),
                                            OutlinedButton.icon(
                                              onPressed: () =>
                                                  _pickPaymentProof(context,
                                                      checkoutProvider, null),
                                              icon: const Icon(Icons
                                                  .add_photo_alternate_outlined),
                                              label: Text(getTranslated(
                                                      'wallet_upload_proof',
                                                      context) ??
                                                  ''),
                                            ),
                                            if (_pickedImage != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(
                                                      _pickedImage!,
                                                      height: 140,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            FormField<String>(
                                              validator: (_) => _pickedImage ==
                                                      null
                                                  ? getTranslated(
                                                      'wallet_proof_required',
                                                      context)
                                                  : null,
                                              builder: (state) => state.hasError
                                                  ? Text(state.errorText!,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error))
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    final methodInformation =
                                        configuredInputs[index];

                                    // إذا كان نوع الحقل القادم من الأدمن image يتم رسم زر اختيار صورة بدلاً من الـ TextField
                                    if (methodInformation.inputType ==
                                        'image') {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeDefault),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${getTranslated(methodInformation.customerInput ?? '', context) ?? methodInformation.customerPlaceholder ?? ''}${methodInformation.isRequired == 1 ? ' *' : ''}',
                                              style: textBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault),
                                            ),
                                            const SizedBox(height: 10),
                                            InkWell(
                                              onTap: () => _pickPaymentProof(
                                                  context,
                                                  checkoutProvider,
                                                  index),
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
                                                          .withValues(
                                                              alpha: 0.5)),
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
                                                if (_pickedImage == null) {
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
                                    final fieldKey =
                                        methodInformation.customerInput ?? '';
                                    final isSenderName =
                                        fieldKey == 'sender_name';
                                    final isSenderIdentifier =
                                        fieldKey == 'sender_wallet_or_phone' ||
                                            fieldKey == 'sender_identifier';
                                    final isInstaPay = checkoutProvider
                                            .selectedTransferChannel ==
                                        'instapay';
                                    final translatedLabel =
                                        getTranslated(fieldKey, context);
                                    final fallbackLabel = (methodInformation
                                                .customerPlaceholder ??
                                            fieldKey)
                                        .replaceAll('_', ' ')
                                        .capitalize();
                                    final label = isSenderName
                                        ? (isInstaPay
                                            ? 'اسم الحساب الخاص بك'
                                            : 'اسم المحفظة الخاصة بك')
                                        : isSenderIdentifier
                                            ? 'الرقم الذي حولت منه'
                                            : translatedLabel != null &&
                                                    translatedLabel != fieldKey
                                                ? translatedLabel
                                                : fallbackLabel;
                                    final hint = isSenderName
                                        ? getTranslated(
                                                'transfer_sender_full_name_hint',
                                                context) ??
                                            label
                                        : isSenderIdentifier
                                            ? getTranslated(
                                                    isInstaPay
                                                        ? 'transfer_sender_instapay_hint'
                                                        : 'transfer_sender_wallet_hint',
                                                    context) ??
                                                label
                                            : (methodInformation
                                                        .customerPlaceholder ??
                                                    label)
                                                .replaceAll('_', ' ')
                                                .capitalize();
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeDefault),
                                      child: CustomTextFieldWidget(
                                        controller: checkoutProvider
                                            .inputFieldControllerList[index],
                                        required: isSenderName ||
                                            isSenderIdentifier ||
                                            methodInformation.isRequired == 1,
                                        labelText: label,
                                        hintText: hint,
                                        inputType: isSenderIdentifier
                                            ? TextInputType.phone
                                            : TextInputType.text,
                                        validator: (value) {
                                          if (isSenderIdentifier &&
                                              !EgyptPhoneHelper.isValidLocal(
                                                  value ?? '')) {
                                            return 'أدخل رقم موبايل مصري صحيحًا من 11 رقمًا.';
                                          }
                                          if (isSenderName ||
                                              isSenderIdentifier ||
                                              methodInformation.isRequired ==
                                                  1) {
                                            return ValidateCheck
                                                .validateEmptyText(value,
                                                    'transfer_field_required');
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          if (!checkoutProvider.keyList
                              .contains('sender_name')) ...[
                            const SizedBox(height: 14),
                            CustomTextFieldWidget(
                              controller: senderNameController,
                              required: true,
                              labelText: getTranslated(
                                  'transfer_sender_full_name', context),
                              hintText: getTranslated(
                                  'transfer_sender_full_name_hint', context),
                              inputAction: TextInputAction.next,
                              inputType: TextInputType.name,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, 'transfer_field_required'),
                            ),
                          ],
                          if (_senderIdentifierIndex(checkoutProvider) < 0) ...[
                            const SizedBox(height: 14),
                            CustomTextFieldWidget(
                              controller: senderIdentifierController,
                              required: true,
                              labelText: getTranslated(
                                  checkoutProvider.selectedTransferChannel ==
                                          'instapay'
                                      ? 'transfer_sender_instapay'
                                      : 'transfer_sender_wallet',
                                  context),
                              hintText: getTranslated(
                                  checkoutProvider.selectedTransferChannel ==
                                          'instapay'
                                      ? 'transfer_sender_instapay_hint'
                                      : 'transfer_sender_wallet_hint',
                                  context),
                              inputAction: TextInputAction.next,
                              inputType: TextInputType.text,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, 'transfer_field_required'),
                            ),
                          ],
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
                    final senderName = _senderName(checkoutProvider);
                    final senderIdentifier =
                        _senderIdentifier(checkoutProvider);
                    if (senderName.isEmpty ||
                        !EgyptPhoneHelper.isValidLocal(senderIdentifier)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(getTranslated(
                                  'transfer_sender_details_required',
                                  context) ??
                              ''),
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
                        senderName: senderName,
                        senderIdentifier:
                            EgyptPhoneHelper.normalizeLocal(senderIdentifier),
                        paymentProofPath: _pickedImage?.path,
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
