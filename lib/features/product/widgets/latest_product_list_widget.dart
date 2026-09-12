import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/slider_product_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product/latest_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:provider/provider.dart';

class LatestProductListWidget extends StatelessWidget {
  const LatestProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (ctx, productController) =>
          productController.latestProductModel,
      builder: (context, latestProductModel, child) {
        if (latestProductModel == null) {
          return const SliderProductShimmerWidget();
        }

        final products = latestProductModel.products ?? [];

        if (products.isEmpty) {
          return const SizedBox();
        }

        return Container(
          padding:
              const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              TitleRowWidget(
                title: getTranslated('latest_products', context),
                onTap: () => RouterHelper.getViewAllProductScreenRoute(
                    productType: ProductType.latestProduct,
                    action: RouteAction.push),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 126,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.homePagePadding),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) => SizedBox(
                    width: MediaQuery.sizeOf(context).width * .82,
                    child: LatestProductWidget(productModel: products[index]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
