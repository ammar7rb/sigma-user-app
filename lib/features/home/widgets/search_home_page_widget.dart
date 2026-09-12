import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SearchHomePageWidget extends StatelessWidget {
  const SearchHomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(
        Dimensions.homePagePadding,
        7,
        Dimensions.homePagePadding,
        9,
      ),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: Provider.of<ThemeController>(context).darkTheme
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .045),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, color: theme.primaryColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              getTranslated('search_hint', context) ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(color: theme.hintColor),
            ),
          ),
          Container(width: 1, height: 22, color: theme.dividerColor),
          const SizedBox(width: 10),
          Icon(
            isLtr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: theme.hintColor,
            size: 20,
          ),
        ]),
      ),
    );
  }
}
