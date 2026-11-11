import 'dart:ui';
import 'package:flutter_sixvalley_ecommerce/features/auth/screens/customer_password_recovery_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/widgets/account_deletion_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_expanded_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/setting/widgets/select_language_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashController>(context, listen: false).setFromSetting(true);
    final localization = Provider.of<LocalizationController>(context);
    return PopScope(
      onPopInvokedWithResult: (_, __) =>
          Provider.of<SplashController>(context, listen: false)
              .setFromSetting(false),
      child: CustomExpandedAppBarWidget(
        title: getTranslated('settings', context),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              children: [
                Text(getTranslated('settings', context) ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                    localization.isLtr
                        ? 'Choose your preferred language'
                        : 'اختر اللغة المناسبة لك',
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 20),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: getTranslated('choose_language', context) ?? '',
                  subtitle: localization.isLtr ? 'English' : 'العربية',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => const SelectLanguageBottomSheetWidget(),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Icon(Icons.payments_outlined,
                        color: Theme.of(context).primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(localization.isLtr
                            ? 'Prices are displayed in Egyptian pounds.'
                            : 'جميع الأسعار معروضة بالجنيه المصري.')),
                  ]),
                ),
                if (context.read<AuthController>().isLoggedIn()) ...[
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: localization.isLtr
                        ? 'Change password'
                        : 'تغيير كلمة المرور',
                    subtitle: localization.isLtr
                        ? 'Open profile security fields'
                        : 'افتح حقول كلمة المرور في الملف الشخصي',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => RouterHelper.getProfileScreen1Route(
                        action: RouteAction.push),
                  ),
                  const SizedBox(height: 18),
                  _SettingsTile(
                    icon: Icons.lock_reset,
                    title: localization.isLtr
                        ? 'Forgot password?'
                        : 'هل نسيت كلمة المرور؟',
                    subtitle: localization.isLtr
                        ? 'Request help recovering your account'
                        : 'طلب استعادة الحساب من الدعم',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: const FractionallySizedBox(
                                heightFactor: .9,
                                child: CustomerPasswordRecoveryScreen()))),
                  ),
                  const SizedBox(height: 18),
                  _SettingsTile(
                    icon: Icons.logout,
                    title: localization.isLtr ? 'Sign out' : 'تسجيل الخروج',
                    subtitle: localization.isLtr
                        ? 'Sign out of this account'
                        : 'تسجيل الخروج من حسابك',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const LogoutCustomBottomSheetWidget()),
                  ),
                  const SizedBox(height: 18),
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    title: localization.isLtr ? 'Delete account' : 'حذف الحساب',
                    subtitle: localization.isLtr
                        ? 'Verify your password to continue'
                        : 'تحقق من كلمة المرور للمتابعة',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: const Material(
                              child: DeleteAccountBottomSheet(customerId: ''))),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.trailing,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor)),
            child: Row(children: [
              Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: Theme.of(context).primaryColor)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor)),
                  ])),
              trailing,
            ]),
          ),
        ),
      );
}
