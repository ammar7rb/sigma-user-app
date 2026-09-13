import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  final bool fromDashboard;
  const CategoryScreen({super.key, this.fromDashboard = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _initialized = false;

  void _selectCategory(int index, CategoryController controller,
      {bool update = true}) {
    final category = controller.categoryList[index];
    controller.onChangeSelectedIndex(index, isUpdate: update);
    Provider.of<ProductController>(context, listen: false)
        .initBrandOrCategoryProductList(
      isBrand: false,
      id: category.id,
      offset: 1,
      isUpdate: update,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.fromDashboard
          ? null
          : CustomAppBar(title: getTranslated('CATEGORY', context)),
      body: SafeArea(
        child: Consumer<CategoryController>(
          builder: (context, categoryController, _) {
            final categories = categoryController.categoryList;
            if (categories.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              );
            }

            if (!_initialized) {
              _initialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _selectCategory(0, categoryController, update: false);
                }
              });
            }

            final selectedIndex =
                (categoryController.categorySelectedIndex ?? 0)
                    .clamp(0, categories.length - 1);
            final selectedCategory = categories[selectedIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.fromDashboard)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.grid_view_rounded,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Text(getTranslated('CATEGORY', context) ?? 'Categories',
                          style: textBold.copyWith(fontSize: 24)),
                    ]),
                  ),
                SizedBox(
                  height: 126,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => CategoryItem(
                      title: categories[index].name,
                      icon: categories[index].imageFullUrl?.path,
                      isSelected: selectedIndex == index,
                      onTap: () => _selectCategory(index, categoryController),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: .28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .045),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _CategoryDetails(category: selectedCategory),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryDetails extends StatelessWidget {
  final CategoryModel category;
  const _CategoryDetails({required this.category});

  @override
  Widget build(BuildContext context) {
    final subCategories = category.subCategories ?? <SubCategory>[];
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(children: [
          Expanded(
            child: Text(category.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(fontSize: 19)),
          ),
          FilledButton.icon(
            onPressed: () => RouterHelper.getBrandCategoryRoute(
              isBrand: false,
              id: category.id,
              name: category.name,
              categoryModel: category,
              isAllProduct: true,
            ),
            icon: const Icon(Icons.apps_rounded, size: 18),
            label:
                Text(getTranslated('view_all_products', context) ?? 'View all'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ]),
      ),
      Divider(height: 1, color: Theme.of(context).dividerColor),
      Expanded(
        child: subCategories.isEmpty
            ? Center(
                child: Text(
                    getTranslated('no_data_found', context) ?? 'No data found',
                    style: TextStyle(color: Theme.of(context).hintColor)),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: subCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final subCategory = subCategories[index];
                  final nested = subCategory.subSubCategories ?? [];
                  if (nested.isNotEmpty) {
                    return _SubCategoryExpansion(
                        subCategory: subCategory, nested: nested);
                  }
                  return _CategoryRow(
                    title: subCategory.name ?? '',
                    icon: Icons.category_outlined,
                    onTap: () => RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: subCategory.id,
                      name: category.name,
                      categoryModel: category,
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

class _SubCategoryExpansion extends StatelessWidget {
  final SubCategory subCategory;
  final List<dynamic> nested;
  const _SubCategoryExpansion({
    required this.subCategory,
    required this.nested,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: const _IconTile(icon: Icons.folder_copy_outlined),
          title: Text(subCategory.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          children: [
            _CategoryRow(
              title: getTranslated('all_products', context) ?? 'All products',
              icon: Icons.apps_rounded,
              onTap: () => RouterHelper.getBrandCategoryRoute(
                action: RouteAction.push,
                isBrand: false,
                id: subCategory.id,
                name: subCategory.name,
                subCategory: subCategory,
                isAllProduct: true,
              ),
            ),
            ...nested.map((item) => Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: _CategoryRow(
                    title: item.name ?? '',
                    icon: Icons.subdirectory_arrow_left_rounded,
                    onTap: () => RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: item.id,
                      name: subCategory.name,
                      subCategory: subCategory,
                    ),
                  ),
                )),
          ],
        ),
      );
}

class _CategoryRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryRow(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              _IconTile(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).hintColor),
            ]),
          ),
        ),
      );
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 21, color: Theme.of(context).primaryColor),
      );
}

class CategoryItem extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;
  const CategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 104,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
              ),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CustomImageWidget(
                    fit: BoxFit.cover, image: '$icon', height: 48, width: 48),
              ),
              const SizedBox(height: 7),
              Text(title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected ? Colors.white : null,
                  )),
            ]),
          ),
        ),
      );
}
