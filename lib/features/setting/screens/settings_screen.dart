import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_expanded_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/setting/widgets/select_language_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashController>(context, listen: false).setFromSetting(true);
    final localization = Provider.of<LocalizationController>(context);
    final themeController = Provider.of<ThemeController>(context);
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
                        ? 'Personalize language and appearance'
                        : 'خصص اللغة ومظهر التطبيق بسهولة',
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 20),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: getTranslated('dark_theme', context) ?? '',
                  subtitle: themeController.darkTheme
                      ? (localization.isLtr
                          ? 'Dark mode is on'
                          : 'الوضع الداكن مفعّل')
                      : (localization.isLtr
                          ? 'Light mode is on'
                          : 'الوضع الفاتح مفعّل'),
                  trailing: Switch.adaptive(
                    value: themeController.darkTheme,
                    onChanged: (_) =>
                        Provider.of<ThemeController>(context, listen: false)
                            .toggleTheme(),
                  ),
                  onTap: () =>
                      Provider.of<ThemeController>(context, listen: false)
                          .toggleTheme(),
                ),
                const SizedBox(height: 12),
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
