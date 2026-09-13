import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';

class ProfileInfoSectionWidget extends StatelessWidget {
  const ProfileInfoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(builder: (context, profile, _) {
      final auth = Provider.of<AuthController>(context, listen: false);
      bool isGuestMode = !auth.isLoggedIn();
      final rememberedAccount = auth.getUserData();
      final hasRememberedAccount =
          (rememberedAccount?.email?.trim().isNotEmpty ?? false) ||
              (rememberedAccount?.phoneNumber?.trim().isNotEmpty ?? false);
      final theme = Provider.of<ThemeController>(context);
      final locale = Provider.of<LocalizationController>(context);
      return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(children: [
            Row(children: [
              Text(getTranslated('profile', context) ?? 'Profile',
                  style: textBold.copyWith(fontSize: 23)),
              const Spacer(),
              _HeaderAction(
                label: locale.isLtr ? 'AR' : 'EN',
                icon: Icons.language_rounded,
                onTap: () => locale.setLanguage(
                  locale.isLtr
                      ? const Locale('ar', 'SA')
                      : const Locale('en', 'US'),
                ),
              ),
              const SizedBox(width: 8),
              _HeaderAction(
                icon: theme.darkTheme
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: theme.toggleTheme,
              ),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF075ACB), Color(0xFF249DEB)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF075ACB).withValues(alpha: .20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(children: [
                InkWell(
                  onTap: () {
                    if (isGuestMode) {
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (_) => NotLoggedInBottomSheetWidget(
                              fromPage: RouterHelper.profileScreen1));
                    } else {
                      if (profile.userInfoModel != null) {
                        RouterHelper.getProfileScreen1Route(
                            action: RouteAction.push);
                      }
                    }
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: .35)),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Provider.of<AuthController>(context,
                                    listen: false)
                                .isLoggedIn()
                            ? CustomImageWidget(
                                image:
                                    '${profile.userInfoModel?.imageFullUrl?.path}',
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                placeholder: Images.guestProfile)
                            : const Icon(Icons.person_outline_rounded,
                                color: Colors.white, size: 32),
                      )),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        !isGuestMode
                            ? '${profile.userInfoModel?.fName ?? ''} ${profile.userInfoModel?.lName ?? ''}'
                            : (getTranslated('welcome_to_eFood', context) ??
                                'Welcome to Sigma'),
                        style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraLarge)),
                    if (!isGuestMode &&
                        profile.userInfoModel?.phone != null &&
                        profile.userInfoModel!.phone!.isNotEmpty)
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    if (!isGuestMode)
                      Text(profile.userInfoModel?.phone ?? '',
                          style: textRegular.copyWith(
                              color: Colors.white.withValues(alpha: .82),
                              fontSize: Dimensions.fontSizeLarge)),
                    if (isGuestMode && hasRememberedAccount) ...[
                      const SizedBox(height: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                        onPressed: () => RouterHelper.getLoginRoute(
                          action: RouteAction.push,
                          fromPage: '${RouterHelper.dashboardScreen}?page=more',
                        ),
                        child: Text(
                            getTranslated('sign_in', context) ?? 'Sign in'),
                      ),
                    ],
                  ],
                )),
                if (!isGuestMode)
                  IconButton(
                    onPressed: () => RouterHelper.getProfileScreen1Route(
                        action: RouteAction.push),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
              ]),
            ),
          ]));
    });
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: SizedBox(
            height: 42,
            width: label == null ? 42 : 58,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              if (label != null) ...[
                const SizedBox(width: 3),
                Text(label!,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ]),
          ),
        ),
      );
}
