import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class FeaturedDealWidget extends StatelessWidget {
  final Product product;
  final bool isHomePage;
  final bool? isCenterElement;
  const FeaturedDealWidget(
      {super.key,
      required this.product,
      required this.isHomePage,
      this.isCenterElement});

  @override
  Widget build(BuildContext context) {
    final discount = (product.clearanceSale?.discountAmount ?? 0) > 0
        ? product.clearanceSale?.discountAmount
        : product.discount;
    final discountType = (product.clearanceSale?.discountAmount ?? 0) > 0
        ? product.clearanceSale?.discountType
        : product.discountType;
    final hasDiscount = (discount ?? 0) > 0;
    final outOfStock =
        (product.currentStock ?? 0) == 0 && product.productType == 'physical';
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => RouterHelper.getProductDetailsRoute(
          action: RouteAction.push, productId: product.id, slug: product.slug),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        margin:
            EdgeInsets.symmetric(vertical: isCenterElement == false ? 5 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: .12)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: .08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(children: [
          Expanded(
            flex: 5,
            child: Stack(children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: .055),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomImageWidget(
                        image: '${product.thumbnailFullUrl?.path}',
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              if (hasDiscount)
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(getTranslated('offer', context) ?? 'Offer',
                        style: textBold.copyWith(
                            fontSize: 11, color: const Color(0xFF087A55))),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (outOfStock)
                  Text(getTranslated('out_of_stock', context) ?? '',
                      style: textMedium.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12)),
                Text(product.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textBold.copyWith(fontSize: 17, height: 1.25)),
                const SizedBox(height: 6),
                if ((int.tryParse(product.reviewCount.toString()) ?? 0) > 0)
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFB547), size: 18),
                    const SizedBox(width: 3),
                    Text(
                        product.rating?.isNotEmpty == true
                            ? double.tryParse(
                                        product.rating!.first.average ?? '0')
                                    ?.toStringAsFixed(1) ??
                                '0.0'
                            : '0.0',
                        style: textMedium),
                    Text('  (${product.reviewCount})',
                        style: textRegular.copyWith(
                            color: Theme.of(context).hintColor)),
                  ]),
                const SizedBox(height: 10),
                if (hasDiscount)
                  Text(
                      PriceConverter.convertPrice(
                          context, (product.unitPrice ?? 0).toDouble()),
                      style: textRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough)),
                Text(
                  PriceConverter.convertPrice(
                      context, (product.unitPrice ?? 0).toDouble(),
                      discountType: discountType, discount: discount),
                  style: textBold.copyWith(
                      color: Theme.of(context).primaryColor, fontSize: 19),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: FavouriteButtonWidget(
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: .10),
              productId: product.id,
            ),
          ),
        ]),
      ),
    );
  }
}
