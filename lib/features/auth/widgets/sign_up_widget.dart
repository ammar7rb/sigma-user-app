import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/models/register_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  final String? referCode;
  const SignUpWidget(
      {super.key,
      required this.fromLogout,
      this.fromPage,
      this.onLoginSuccess,
      this.referCode});
  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final _firstName = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _firstName.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<SplashController>().configModel;
    final auth = context.watch<AuthController>();
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Form(
        key: _form,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              CustomTextFieldWidget(
                  controller: _firstName,
                  labelText: getTranslated('first_name', context),
                  inputType: TextInputType.name,
                  inputAction: TextInputAction.next,
                  required: false),
              const SizedBox(height: 16),
              CustomTextFieldWidget(
                  controller: _phone,
                  labelText: getTranslated('enter_mobile_number', context),
                  hintText: '01xxxxxxxxx',
                  inputType: TextInputType.phone,
                  inputAction: TextInputAction.next,
                  showCodePicker: false,
                  required: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)
                  ],
                  validator: (value) =>
                      EgyptPhoneHelper.isValidLocal(value ?? '')
                          ? null
                          : getTranslated('enter_valid_phone_number', context)),
              const SizedBox(height: 16),
              CustomTextFieldWidget(
                  controller: _password,
                  labelText: getTranslated('password', context),
                  hintText:
                      arabic ? '6 أحرف على الأقل' : 'At least 6 characters',
                  isPassword: true,
                  required: true,
                  inputAction: TextInputAction.done,
                  validator: (value) => (value ?? '').length < 6
                      ? (arabic
                          ? 'أدخل كلمة مرور من 6 أحرف على الأقل'
                          : 'Enter at least 6 characters')
                      : null),
              const SizedBox(height: 24),
              CustomButton(
                  isLoading: auth.isLoading,
                  buttonText: getTranslated('sign_up', context),
                  onTap: config == null || auth.isLoading
                      ? null
                      : () {
                          if (!(_form.currentState?.validate() ?? false)) {
                            return;
                          }
                          final registration = RegisterModel(
                              fName: _firstName.text.trim(),
                              password: _password.text,
                              referCode: widget.referCode)
                            ..phone =
                                EgyptPhoneHelper.toInternational(_phone.text);
                          auth.registration(
                              registration,
                              (dynamic a, dynamic b, dynamic c, dynamic d) {},
                              config,
                              widget.fromPage,
                              widget.onLoginSuccess);
                        }),
            ])));
  }
}
