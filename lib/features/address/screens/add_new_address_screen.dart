import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/location/controllers/location_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/country_code_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_location_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shipping/controllers/shipping_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final bool? isBilling;
  const AddNewAddressScreen(
      {super.key,
      this.isEnableUpdate = false,
      this.address,
      this.fromCheckout = false,
      this.isBilling});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonEmailController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  String? _selectedGovernorate;
  String _selectedShippingOption = 'normal';
  final FocusNode _zipNode = FocusNode();
  GoogleMapController? _controller;
  CameraPosition? _cameraPosition;
  bool _updateAddress = true;
  static const String _egyptDialCode = '+20';
  static const String _egyptCountryName = 'Egypt';
  static const LatLng _egyptCenter = LatLng(26.8206, 30.8025);
  final bool _mapAddressPickerEnabled = false;
  String zip = '', country = 'EG';
  late final LatLng _defaut = _egyptCenter;

  final GlobalKey<FormState> _addressFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Billing addresses are not part of this checkout. Every saved address is
    // a delivery address, so users never need to choose a second type here.

    Provider.of<AuthController>(context, listen: false)
        .setCountryCode(_egyptDialCode, notify: false);
    _countryCodeController.text = _egyptCountryName;
    Provider.of<AddressController>(context, listen: false).getAddressType();
    Provider.of<AddressController>(context, listen: false)
        .getShippingGovernorates();
    Provider.of<AddressController>(context, listen: false)
        .getRestrictedDeliveryCountryList();
    Provider.of<AddressController>(context, listen: false)
        .getRestrictedDeliveryZipList();

    if (widget.isEnableUpdate && widget.address != null) {
      Provider.of<LocationController>(context, listen: false)
          .locationController
          .text = widget.address!.address ?? '';
      _contactPersonNameController.text =
          '${widget.address?.contactPersonName}';
      _countryCodeController.text = _egyptCountryName;
      _contactPersonEmailController.text = '${widget.address?.email}';
      // _contactPersonNumberController.text = '${widget.address?.phone}';
      _cityController.text = '${widget.address?.city}';
      final savedGovernorate = widget.address?.state ?? _cityController.text;
      if (EgyptLocationHelper.governorates.contains(savedGovernorate)) {
        _selectedGovernorate = savedGovernorate;
      }
      _zipCodeController.text = '${widget.address?.zip}';
      _districtController.text =
          widget.address?.district ?? widget.address?.area ?? '';
      _streetController.text = widget.address?.street ?? '';
      _landmarkController.text = widget.address?.landmark ?? '';
      if (widget.address!.addressType == 'Home') {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(0, false);
      } else if (widget.address!.addressType == 'Workplace') {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(1, false);
      } else {
        Provider.of<AddressController>(context, listen: false)
            .updateAddressIndex(2, false);
      }
      String countryCode = _egyptDialCode;
      Provider.of<AuthController>(context, listen: false)
          .setCountryCode(countryCode, notify: false);
      String phoneNumberOnly = CountryCodeHelper.extractPhoneNumber(
          countryCode, widget.address?.phone ?? '');
      _contactPersonNumberController.text = phoneNumberOnly;
    } else {
      if (Provider.of<ProfileController>(context, listen: false)
              .userInfoModel !=
          null) {
        _contactPersonNameController.text =
            '${Provider.of<ProfileController>(context, listen: false).userInfoModel!.fName ?? ''}'
            ' ${Provider.of<ProfileController>(context, listen: false).userInfoModel!.lName ?? ''}';

        String countryCode = _egyptDialCode;
        Provider.of<AuthController>(context, listen: false)
            .setCountryCode(countryCode);
        String phoneNumberOnly = CountryCodeHelper.extractPhoneNumber(
            countryCode,
            Provider.of<ProfileController>(context, listen: false)
                    .userInfoModel!
                    .phone ??
                '');
        _contactPersonNumberController.text = phoneNumberOnly;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.isEnableUpdate
              ? getTranslated('update_address', context)
              : getTranslated('add_new_address', context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_location_alt_outlined,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    getTranslated('address_form_hint', context) ??
                        'أضف بيانات التوصيل بدقة لحساب الشحن وموعد الوصول.',
                    style: textMedium.copyWith(height: 1.45),
                  ),
                ),
              ]),
            ),
            Consumer<AddressController>(
              builder: (context, addressController, child) {
                return Consumer<LocationController>(
                    builder: (context, locationController, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Form(
                      key: _addressFormKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeLarge),
                                child: CustomTextFieldWidget(
                                  required: true,
                                  prefixIcon: Images.user,
                                  labelText: getTranslated(
                                      'enter_contact_person_name', context),
                                  hintText: getTranslated(
                                      'enter_contact_person_name', context),
                                  inputType: TextInputType.name,
                                  controller: _contactPersonNameController,
                                  focusNode: _nameNode,
                                  nextFocus: _numberNode,
                                  inputAction: TextInputAction.next,
                                  capitalization: TextCapitalization.words,
                                  validator: (value) =>
                                      ValidateCheck.validateEmptyText(value,
                                          'contact_person_name_is_required'),
                                )),

                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            Consumer<AuthController>(
                                builder: (context, authProvider, _) {
                              return CustomTextFieldWidget(
                                required: true,
                                labelText: getTranslated('phone', context),
                                hintText: getTranslated(
                                    'enter_mobile_number', context),
                                controller: _contactPersonNumberController,
                                focusNode: _numberNode,
                                nextFocus: _emailNode,
                                showCodePicker: false,
                                countryDialCode: _egyptDialCode,
                                isAmount: true,
                                validator: (value) =>
                                    ValidateCheck.validateEmptyText(
                                        value, "phone_must_be_required"),
                                inputAction: TextInputAction.next,
                                inputType: TextInputType.phone,
                              );
                            }),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            if (!Provider.of<AuthController>(context,
                                    listen: false)
                                .isLoggedIn())
                              CustomTextFieldWidget(
                                required: true,
                                prefixIcon: Images.email,
                                labelText: getTranslated('email', context),
                                hintText: getTranslated(
                                    'enter_contact_person_email', context),
                                inputType: TextInputType.emailAddress,
                                controller: _contactPersonEmailController,
                                focusNode: _emailNode,
                                nextFocus: _addressNode,
                                inputAction: TextInputAction.next,
                                capitalization: TextCapitalization.words,
                                validator: (value) =>
                                    ValidateCheck.validateEmail(value),
                              ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            _mapAddressPickerEnabled &&
                                    Provider.of<SplashController>(context,
                                                listen: false)
                                            .configModel!
                                            .mapApiStatus ==
                                        1
                                ? SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              GoogleMap(
                                                  mapType: MapType.normal,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                          target: widget
                                                                  .isEnableUpdate
                                                              ? LatLng(
                                                                  (widget.address!.latitude != null &&
                                                                          widget.address!.latitude !=
                                                                              '0' &&
                                                                          widget.address!.latitude !=
                                                                              '')
                                                                      ? double.parse(widget
                                                                          .address!
                                                                          .latitude!)
                                                                      : _defaut
                                                                          .latitude,
                                                                  (widget.address!.longitude != null &&
                                                                          widget.address!.longitude !=
                                                                              '0' &&
                                                                          widget.address!.longitude !=
                                                                              '')
                                                                      ? double.parse(widget
                                                                          .address!
                                                                          .longitude!)
                                                                      : _defaut
                                                                          .longitude,
                                                                )
                                                              : _isInsideEgypt(LatLng(
                                                                      locationController
                                                                          .position
                                                                          .latitude,
                                                                      locationController
                                                                          .position
                                                                          .longitude))
                                                                  ? LatLng(
                                                                      locationController
                                                                          .position
                                                                          .latitude,
                                                                      locationController
                                                                          .position
                                                                          .longitude)
                                                                  : _egyptCenter,
                                                          zoom: 16),
                                                  cameraTargetBounds:
                                                      CameraTargetBounds(LatLngBounds(
                                                          southwest:
                                                              const LatLng(
                                                                  21.5, 24.5),
                                                          northeast:
                                                              const LatLng(
                                                                  31.8, 37.2))),
                                                  onTap: (latLng) {
                                                    RouterHelper
                                                        .getSelectLocationScreen(
                                                            googleMapController:
                                                                _controller,
                                                            action: RouteAction
                                                                .push);
                                                  },
                                                  zoomControlsEnabled: false,
                                                  compassEnabled: false,
                                                  indoorViewEnabled: true,
                                                  mapToolbarEnabled: false,
                                                  onCameraIdle: () {
                                                    if (_updateAddress) {
                                                      locationController
                                                          .updateMapPosition(
                                                              _cameraPosition,
                                                              true,
                                                              null,
                                                              context);
                                                    } else {
                                                      _updateAddress = true;
                                                    }
                                                  },
                                                  onCameraMove: ((position) =>
                                                      _cameraPosition =
                                                          position),
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) {
                                                    _controller = controller;
                                                    if (!widget
                                                            .isEnableUpdate &&
                                                        _controller != null) {
                                                      locationController
                                                          .getCurrentLocation(
                                                              context, true,
                                                              mapController:
                                                                  _controller);
                                                    }
                                                  }),
                                              locationController.loading
                                                  ? Center(
                                                      child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(Theme.of(
                                                                      context)
                                                                  .primaryColor)))
                                                  : const SizedBox(),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  alignment: Alignment.center,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 40,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  )),
                                              Positioned(
                                                  top: 10,
                                                  right: 0,
                                                  child: InkWell(
                                                      onTap: () => RouterHelper
                                                          .getSelectLocationScreen(
                                                              googleMapController:
                                                                  _controller,
                                                              action:
                                                                  RouteAction
                                                                      .push),
                                                      child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          margin: const EdgeInsets
                                                              .only(
                                                              right: Dimensions
                                                                  .paddingSizeLarge),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .paddingSizeSmall),
                                                            color: Colors.white,
                                                          ),
                                                          child: Icon(
                                                              Icons.fullscreen,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              size: 20))))
                                            ])))
                                : const SizedBox(),

                            CustomTextFieldWidget(
                              labelText:
                                  getTranslated('delivery_address', context),
                              hintText: getTranslated(
                                  'shipping_address_details', context),
                              inputType: TextInputType.streetAddress,
                              inputAction: TextInputAction.next,
                              focusNode: _addressNode,
                              prefixIcon: Images.address,
                              required: true,
                              nextFocus: _zipNode,
                              controller: locationController.locationController,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, "address_is_required"),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            CustomTextFieldWidget(
                              required: true,
                              labelText: 'الحي أو المنطقة',
                              hintText: 'مثال: الحي السابع',
                              prefixIcon: Images.city,
                              controller: _districtController,
                              inputType: TextInputType.streetAddress,
                              inputAction: TextInputAction.next,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, 'area_is_required'),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            CustomTextFieldWidget(
                              required: true,
                              labelText: 'الشارع',
                              hintText: 'اسم الشارع ورقم المبنى',
                              prefixIcon: Images.address,
                              controller: _streetController,
                              inputType: TextInputType.streetAddress,
                              inputAction: TextInputAction.next,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, 'street_is_required'),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            CustomTextFieldWidget(
                              labelText: 'علامة مميزة',
                              hintText: 'مثال: بجوار مستشفى أو صيدلية',
                              prefixIcon: Images.address,
                              controller: _landmarkController,
                              inputType: TextInputType.streetAddress,
                              inputAction: TextInputAction.next,
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            // Egypt is fixed internally. The country selector is
                            // deliberately hidden from the customer.
                            ...<Widget>[
                              Text(getTranslated('country', context)!,
                                  style: textRegular.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeSmall,
                                  )),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              SizedBox(
                                  height: 60,
                                  child: Consumer<AddressController>(
                                      builder: (context, addressController, _) {
                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeDefault),
                                            decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    width: .1,
                                                    color: Theme.of(context)
                                                        .hintColor
                                                        .withValues(
                                                            alpha: 0.1))),
                                            child: Row(children: [
                                              Image.asset(Images.country),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall),
                                              Text(_egyptCountryName,
                                                  style: textRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color)),
                                            ]),
                                          ),
                                        ]);
                                  })),
                            ].where((_) => false),

                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGovernorate,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText:
                                    getTranslated('governorate', context),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor),
                                ),
                                prefixIconConstraints:
                                    const BoxConstraints.tightFor(
                                        width: 52, height: 52),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Image.asset(Images.city,
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.contain),
                                ),
                              ),
                              hint: Text(
                                  getTranslated('governorate', context) ??
                                      'Governorate'),
                              items: (addressController
                                          .shippingGovernorates.isNotEmpty
                                      ? addressController.shippingGovernorates
                                      : EgyptLocationHelper.governorates)
                                  .map(
                                      (governorate) => DropdownMenuItem<String>(
                                            value: governorate,
                                            child: Text(governorate,
                                                style: textRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault)),
                                          ))
                                  .toList(),
                              validator: (value) => value == null
                                  ? getTranslated(
                                      'governorate_is_required', context)
                                  : null,
                              onChanged: (value) => setState(() {
                                _selectedGovernorate = value;
                              }),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context).hintColor),
                            ),

                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),
                            CustomTextFieldWidget(
                              required: true,
                              prefixIcon: Images.city,
                              labelText: getTranslated('city', context),
                              hintText: getTranslated('city', context),
                              inputType: TextInputType.text,
                              controller: _cityController,
                              focusNode: _zipNode,
                              inputAction: TextInputAction.next,
                              validator: (value) =>
                                  ValidateCheck.validateEmptyText(
                                      value, 'city_is_required'),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            if (widget.fromCheckout) ...[
                              Text(
                                getTranslated(
                                        'select_shipping_method', context) ??
                                    'Select shipping method',
                                style: textBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault),
                              ),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                  child: _ShippingOptionCard(
                                    selected:
                                        _selectedShippingOption == 'normal',
                                    icon: Icons.local_shipping_outlined,
                                    title: getTranslated(
                                            'normal_shipping', context) ??
                                        'Normal shipping',
                                    onTap: () => setState(() =>
                                        _selectedShippingOption = 'normal'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ShippingOptionCard(
                                    selected:
                                        _selectedShippingOption == 'sigma',
                                    icon: Icons.bolt_rounded,
                                    title: getTranslated(
                                            'sigma_shipping', context) ??
                                        'Sigma shipping',
                                    onTap: () => setState(() =>
                                        _selectedShippingOption = 'sigma'),
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefaultAddress),
                            ],

                            const SizedBox(
                                height: Dimensions.paddingSizeDefaultAddress),

                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: CustomButton(
                                isLoading: addressController.isLoading,
                                buttonText: widget.isEnableUpdate
                                    ? getTranslated('update_address', context)
                                    : getTranslated('save_location', context),
                                onTap: addressController.isLoading
                                    ? null
                                    : () async {
                                        if (_addressFormKey.currentState
                                                ?.validate() ??
                                            false) {
                                          AddressModel addressModel =
                                              AddressModel(
                                            addressType: 'Home',
                                            contactPersonName:
                                                _contactPersonNameController
                                                    .text,
                                            phone:
                                                '${Provider.of<AuthController>(context, listen: false).countryDialCode}${_contactPersonNumberController.text.trim()}',
                                            email: _contactPersonEmailController
                                                .text
                                                .trim(),
                                            // The API retains city for backwards compatibility; state
                                            // carries the explicit governorate used by Egypt shipping.
                                            state: _selectedGovernorate,
                                            city: _cityController.text,
                                            zip: _zipCodeController.text,
                                            country:
                                                _countryCodeController.text,
                                            guestId:
                                                Provider.of<AuthController>(
                                                        context,
                                                        listen: false)
                                                    .getGuestToken(),
                                            isBilling: false,
                                            address: locationController
                                                .locationController.text,
                                            latitude: null,
                                            longitude: null,
                                            district:
                                                _districtController.text.trim(),
                                            area:
                                                _districtController.text.trim(),
                                            street:
                                                _streetController.text.trim(),
                                            landmark:
                                                _landmarkController.text.trim(),
                                          );

                                          if (widget.isEnableUpdate) {
                                            addressModel.id =
                                                widget.address!.id;
                                            addressController.updateAddress(
                                                context,
                                                addressModel: addressModel,
                                                addressId: addressModel.id);
                                          } else {
                                            final value =
                                                await addressController
                                                    .addAddress(addressModel);
                                            if (value.response?.statusCode !=
                                                    200 ||
                                                !context.mounted) {
                                              return;
                                            }

                                            if (widget.fromCheckout) {
                                              final addressId = int.tryParse(
                                                  '${value.response?.data['address_id'] ?? ''}');
                                              if (addressId == null) return;
                                              final shipping = Provider.of<
                                                      ShippingController>(
                                                  context,
                                                  listen: false);
                                              if (!await shipping
                                                      .quoteForAddress(
                                                          context, addressId) ||
                                                  !context.mounted) {
                                                return;
                                              }
                                              if (!await shipping
                                                      .selectQuoteForAddress(
                                                          context,
                                                          addressId,
                                                          _selectedShippingOption) ||
                                                  !context.mounted) {
                                                return;
                                              }
                                              final addresses =
                                                  await addressController
                                                      .getAddressList();
                                              final index = addresses
                                                      ?.indexWhere((item) =>
                                                          item.id ==
                                                          addressId) ??
                                                  -1;
                                              if (index >= 0 &&
                                                  context.mounted) {
                                                Provider.of<CheckoutController>(
                                                        context,
                                                        listen: false)
                                                    .setAddressIndex(index);
                                                final navigator =
                                                    Navigator.of(context);
                                                navigator.pop();
                                                if (navigator.canPop()) {
                                                  navigator.pop();
                                                }
                                              }
                                              return;
                                            }
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                              ),
                            ),
                          ]),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Retained only for the dormant legacy map widget. Customer checkout keeps
  // that widget disabled and prices delivery from the governorate form.
  static bool _isInsideEgypt(LatLng point) =>
      point.latitude >= 21.5 &&
      point.latitude <= 31.8 &&
      point.longitude >= 24.5 &&
      point.longitude <= 37.2;
}

enum Address { shipping, billing }

class _ShippingOptionCard extends StatelessWidget {
  const _ShippingOptionCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor.withValues(alpha: .09)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Icon(icon,
                size: 22,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(fontSize: 13)),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
            ),
          ]),
        ),
      );
}
