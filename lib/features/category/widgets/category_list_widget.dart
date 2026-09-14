import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

import 'category_shimmer_widget.dart';

class CategoryListWidget extends StatelessWidget {
  final bool isHomePage;
  const CategoryListWidget({super.key, required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryProvider, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: .045),
              blurRadius: 18,
              offset: const Offset(0, 7),
            )],
          ),
          child: Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraExtraSmall),
            child: TitleRowWidget(
              title: getTranslated('CATEGORY', context),
              onTap: () {
                if(categoryProvider.categoryList.isNotEmpty) {
                  RouterHelper.getCategoryScreenRoute(action: RouteAction.push);
                }
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          categoryProvider.categoryList.isNotEmpty ?
          SizedBox(height: 126,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: categoryProvider.categoryList.length > 10 ? 10 : categoryProvider.categoryList.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell( splashColor: Colors.transparent, highlightColor: Colors.transparent,
                  onTap: () {
                    RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: categoryProvider.categoryList[index].id,
                      name: categoryProvider.categoryList[index].name,
                    );
                  },
                  child: CategoryWidget(
                    category: categoryProvider.categoryList[index],
                    index: index,length:  categoryProvider.categoryList.length
                  ),
                );
              },
            ),
          ) : const CategoryShimmerWidget(),
        ]));

      },
    );
  }
}
