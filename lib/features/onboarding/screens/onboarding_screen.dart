import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  final Color indicatorColor;
  final Color selectedIndicatorColor;
  OnBoardingScreen(
      {super.key,
      this.indicatorColor = Colors.grey,
      this.selectedIndicatorColor = Colors.black});

  final PageController _pageController = PageController();

  void _finish(BuildContext context) {
    Provider.of<SplashController>(context, listen: false).disableIntro();
    Provider.of<AuthController>(context, listen: false).getGuestIdUrl();
    RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingController>(context, listen: false)
        .getOnBoardingList();
    return Scaffold(
      body: SafeArea(
        child:
            Consumer<OnBoardingController>(builder: (context, controller, _) {
          final pages = controller.onBoardingList;
          final isLast =
              pages.isNotEmpty && controller.selectedIndex == pages.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 4),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.health_and_safety_outlined,
                      color: Theme.of(context).primaryColor),
                ),
                const Spacer(),
                if (!isLast)
                  TextButton(
                    onPressed: () => _finish(context),
                    child: Text(getTranslated('skip', context) ?? 'Skip'),
                  ),
              ]),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: controller.changeSelectIndex,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
                    child: Column(children: [
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: .09),
                                Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: .015),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Image.asset(page.imageUrl,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(page.title ?? '',
                          textAlign: TextAlign.center,
                          style: titilliumBold.copyWith(fontSize: 25)),
                      const SizedBox(height: 10),
                      Text(page.description ?? '',
                          textAlign: TextAlign.center,
                          style: textRegular.copyWith(
                              height: 1.6,
                              fontSize: 16,
                              color: Theme.of(context).hintColor)),
                      const Spacer(),
                    ]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (index) {
                    final selected = index == controller.selectedIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: selected ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: pages.isEmpty
                        ? null
                        : () {
                            if (isLast) {
                              _finish(context);
                            } else {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic);
                            }
                          },
                    icon: Icon(isLast
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded),
                    label: Text(isLast
                        ? (getTranslated('explore', context) ?? 'Explore')
                        : (getTranslated('continue', context) ?? 'Continue')),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                    ),
                  ),
                ),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}
