import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class MenuButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final bool isNotification;
  final bool isProfile;
  final Function? onTap;
  const MenuButtonWidget(
      {super.key,
      required this.image,
      required this.title,
      this.navigateTo,
      this.isNotification = false,
      this.isProfile = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    Widget? badge = isNotification &&
            Provider.of<AuthController>(context, listen: false).isLoggedIn()
        ? Consumer<NotificationController>(
            builder: (context, notificationController, _) {
            return CircleAvatar(
              radius: 12,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                  notificationController.notificationModel?.newNotificationItem
                          .toString() ??
                      '0',
                  style: textRegular.copyWith(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      fontSize: Dimensions.fontSizeSmall)),
            );
          })
        : isProfile
            ? Consumer<ProfileController>(
                builder: (context, profileProvider, _) {
                return CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                        profileProvider.userInfoModel?.referCount.toString() ??
                            '0',
                        style: textRegular.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontSize: Dimensions.fontSizeSmall)));
              })
            : null;
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (badge != null) ...[badge, const SizedBox(width: 7)],
          Icon(Icons.chevron_right_rounded,
              color: Theme.of(context).hintColor, size: 22),
        ]),
        leading: Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Image.asset(image, fit: BoxFit.contain, color: primary),
        ),
        title: Text(title ?? '',
            style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.w600)),
        onTap: onTap != null ? () => onTap!() : () {});
  }
}
