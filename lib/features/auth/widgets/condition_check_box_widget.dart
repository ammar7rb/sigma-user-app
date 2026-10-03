import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ConditionCheckBox extends StatelessWidget {
  const ConditionCheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = context.watch<SplashController>().defaultBusinessPages ?? [];
    final matches = pages.where((page) => page.slug == 'terms-and-conditions');
    final page = matches.isEmpty ? null : matches.first;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Consumer<AuthController>(
          builder: (context, auth, _) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 32,
                      height: 40,
                      child: Checkbox(
                        value: auth.isAcceptTerms,
                        onChanged: (_) => auth.toggleTermsCheck(),
                        semanticLabel: page?.title,
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              getTranslated('i_agree_with_the', context) ?? '',
                              style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall),
                            )),
                        TextButton(
                          onPressed: page == null
                              ? null
                              : () => RouterHelper.getHtmlViewRoute(page: page),
                          child: Text(
                              page?.title ??
                                  (getTranslated('terms_condition', context) ??
                                      ''),
                              style: textMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline)),
                        ),
                      ])),
                ],
              )),
    );
  }
}

class ConditionCheckBoxTwoLine extends StatelessWidget {
  const ConditionCheckBoxTwoLine({super.key});
  @override
  Widget build(BuildContext context) => const ConditionCheckBox();
}
