import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:provider/provider.dart';

class MoreHorizontalSection extends StatelessWidget {
  const MoreHorizontalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;

    final bool isGuestMode =
        !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    final items = <_QuickItem>[
      if (!isGuestMode)
        _QuickItem(
            Icons.account_balance_wallet_rounded,
            getTranslated('wallet_my_wallet', context) ?? 'Wallet',
            () => RouterHelper.getWalletRoute(
                action: RouteAction.push, isBackButtonExist: true)),
      _QuickItem(
          Icons.shopping_cart_rounded,
          getTranslated('cart', context) ?? 'Cart',
          () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
          badge: Provider.of<CartController>(context, listen: false)
              .cartList
              .length),
      _QuickItem(
          Icons.favorite_rounded,
          getTranslated('wishlist', context) ?? 'Wishlist',
          () => RouterHelper.getWishListRoute(action: RouteAction.push),
          badge:
              Provider.of<WishListController>(context).wishList?.length ?? 0),
      if (isGuestMode)
        _QuickItem(
            Icons.local_offer_rounded,
            getTranslated('offers', context) ?? 'Offers',
            () => RouterHelper.getOfferProductListScreenRoute(
                action: RouteAction.push)),
      if (!isGuestMode && configModel?.loyaltyPointStatus == 1)
        _QuickItem(
            Icons.workspace_premium_rounded,
            getTranslated('loyalty_point', context) ?? 'Loyalty',
            () => RouterHelper.getLoyaltyPointScreenRoute(
                action: RouteAction.push)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: items
            .take(4)
            .map((item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _QuickCard(item: item),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;
  const _QuickItem(this.icon, this.label, this.onTap, {this.badge = 0});
}

class _QuickCard extends StatelessWidget {
  final _QuickItem item;
  const _QuickCard({required this.item});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 94,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: .13),
              ),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon,
                      color: Theme.of(context).primaryColor, size: 21),
                ),
                if (item.badge > 0)
                  Positioned(
                    top: -6,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFF4D5E), shape: BoxShape.circle),
                      child: Text('${item.badge}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
              ]),
              const SizedBox(height: 7),
              Text(item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );
}
