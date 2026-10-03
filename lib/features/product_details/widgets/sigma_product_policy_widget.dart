import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

class SigmaProductPolicyWidget extends StatelessWidget {
  const SigmaProductPolicyWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final arabic = Directionality.of(context) == TextDirection.rtl;
    final pages = context.watch<SplashController>().defaultBusinessPages ?? [];
    final terms = pages.where((page) => page.slug == 'terms-and-conditions');
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              arabic
                  ? 'ضمان السلعة وعيوب الصناعة يخضع لسياسة المصنع أو التاجر الأصلي. تساعدكم سيجما في الاستبدال أو الاسترجاع وفقًا لشروط المورد.'
                  : 'Product warranty and manufacturing defects are subject to the manufacturer or original supplier policy. SIGMA assists with replacements and returns under the supplier terms.',
              style: TextStyle(
                  fontSize: 13,
                  height: 1.8,
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          if (terms.isNotEmpty)
            TextButton(
                onPressed: () =>
                    RouterHelper.getHtmlViewRoute(page: terms.first),
                child: Text(arabic
                    ? 'الشروط والأحكام وسياسة الخصوصية'
                    : 'Terms, Conditions & Privacy Policy')),
        ]));
  }
}
