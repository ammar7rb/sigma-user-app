import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CustomMenuWidget extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String icon;
  final bool showCartCount;
  final VoidCallback onTap;

  const CustomMenuWidget({
    super.key,
    required this.isSelected,
    required this.name,
    required this.icon,
    required this.onTap,
    this.showCartCount = false,
  });

  IconData _iconForName() {
    switch (name) {
      case 'home':
        return Icons.home_rounded;
      case 'inbox':
        return Icons.chat_bubble_rounded;
      case 'CATEGORY':
        return Icons.grid_view_rounded;
      case 'cart':
        return Icons.shopping_cart_rounded;
      case 'orders':
        return Icons.receipt_long_rounded;
      case 'more':
      case 'profile':
        return Icons.person_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
        child: SizedBox(
            width: isSelected ? 82 : 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 48 : 38,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Stack(children: [
                    Icon(
                      _iconForName(),
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).hintColor,
                      size: 23,
                    ),
                    if (showCartCount)
                      Positioned.fill(
                          child: Container(
                        transform: Matrix4.translationValues(5, -3, 0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Consumer<CartController>(
                              builder: (context, cart, child) {
                            return (cart.cartList.isNotEmpty)
                                ? CircleAvatar(
                                    radius: ResponsiveHelper.isTab(context)
                                        ? 10
                                        : 7,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    child: Text(cart.cartList.length.toString(),
                                        style: titilliumSemiBold.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                        )))
                                : SizedBox();
                          }),
                        ),
                      )),
                  ]),
                ),
                const SizedBox(height: 2),
                isSelected
                    ? Text(getTranslated(name, context) ?? name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(
                            color: Theme.of(context).primaryColor))
                    : Text(getTranslated(name, context) ?? name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                            color: Theme.of(context).hintColor)),
              ],
            )),
      ),
    );
  }
}
