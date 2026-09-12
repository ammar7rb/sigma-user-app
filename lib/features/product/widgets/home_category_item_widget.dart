import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/home_category_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class HomeCategoryProductItemWidget extends StatelessWidget {
  final HomeCategoryProduct homeCategoryProduct;
  final int index;
  final bool isHomePage;
  const HomeCategoryProductItemWidget(
      {super.key,
      required this.homeCategoryProduct,
      required this.index,
      required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index.isEven
          ? Theme.of(context).cardColor
          : Theme.of(context).colorScheme.onTertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHomePage) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TitleRowWidget(
              title: homeCategoryProduct.name,
              onTap: () {
                RouterHelper.getBrandCategoryRoute(
                  action: RouteAction.push,
                  isBrand: false,
                  id: homeCategoryProduct.id,
                  name: homeCategoryProduct.name,
                );
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
          if (homeCategoryProduct.products!.isNotEmpty)
            SizedBox(
              height: 292,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.homePagePadding),
                physics: const BouncingScrollPhysics(),
                itemCount:
                    isHomePage && homeCategoryProduct.products!.length > 10
                        ? 10
                        : homeCategoryProduct.products!.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                itemBuilder: (context, i) => SizedBox(
                  width: 176,
                  child: InkWell(
                    onTap: () => RouterHelper.getProductDetailsRoute(
                      action: RouteAction.push,
                      productId: homeCategoryProduct.products![i].id!,
                      slug: homeCategoryProduct.products![i].slug!,
                    ),
                    child: ProductWidget(
                        productModel: homeCategoryProduct.products![i]),
                  ),
                ),
              ),
            ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
