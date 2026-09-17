import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/sigma_responsive_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/screens/pending_post_purchase_invoices_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/domain/models/account_overview_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/screens/customer_wallet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/profile_info_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/more_horizontal_section_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/title_button_widget.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _AccountOverviewSection extends StatelessWidget {
  final AccountOverviewModel? data;
  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;
  final Future<void> Function() onChanged;

  const _AccountOverviewSection({
    required this.data,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onChanged,
  });

  String _compact(dynamic raw) {
    final value = double.tryParse('$raw') ?? 0;
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = data?.pendingInvoicesCount ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0,
          Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: data == null
            ? Container(
                key: ValueKey(error ?? loading),
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: error == null
                    ? const CircularProgressIndicator()
                    : TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(error!),
                      ),
              )
            : Column(children: [
                Row(children: [
                  Expanded(
                    child: _BalanceCard(
                      title: getTranslated('purchase_balance', context) ??
                          'Purchase balance',
                      value:
                          '${_compact(data!.purchaseBalance)} ${getTranslated('egp_short', context) ?? 'EGP'}',
                      icon: Icons.account_balance_wallet_rounded,
                      color: Theme.of(context).primaryColor,
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CustomerWalletScreen(
                              initialWallet: 'purchase'),
                        ));
                        await onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BalanceCard(
                      title: getTranslated('insurance_balance', context) ??
                          'Insurance balance',
                      value:
                          '${_compact(data!.insuranceAvailableBalance)} ${getTranslated('egp_short', context) ?? 'EGP'}',
                      icon: Icons.verified_user_rounded,
                      color: const Color(0xFF14A673),
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CustomerWalletScreen(
                              initialWallet: 'insurance'),
                        ));
                        await onChanged();
                      },
                    ),
                  ),
                ]),
                if (data!.insuranceEnabled ||
                    data!.taxEnabled ||
                    pendingCount > 0) ...[
                  const SizedBox(height: 10),
                  Material(
                    color: pendingCount > 0
                        ? const Color(0xFFFFF3D9)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              const PendingPostPurchaseInvoicesScreen(),
                        ));
                        await onChanged();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.pending_actions_rounded,
                                color: Color(0xFFE88700)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslated('pending_completion_orders',
                                          context) ??
                                      'Pending completion orders',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  pendingCount > 0
                                      ? '${getTranslated('pending_orders_count', context) ?? 'Pending'}: $pendingCount'
                                      : getTranslated(
                                              'no_pending_completion_orders',
                                              context) ??
                                          'No pending orders',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (pendingCount > 0)
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE88700),
                                shape: BoxShape.circle,
                              ),
                              child: Text('$pendingCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded),
                        ]),
                      ),
                    ),
                  ),
                ],
              ]),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Future<void> Function() onTap;
  const _BalanceCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: .18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 3),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 11)),
                const SizedBox(height: 8),
                Text(getTranslated('wallet_make_deposit', context) ?? 'Deposit',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}

class _MoreScreenState extends State<MoreScreen> {
  String? version;
  bool singleVendor = false;
  AccountOverviewModel? _walletOverview;
  String? _walletOverviewError;
  bool _walletOverviewLoading = false;

  @override
  void initState() {
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      version = Provider.of<SplashController>(context, listen: false)
              .configModel!
              .softwareVersion ??
          'version';
      Provider.of<ProfileController>(context, listen: false)
          .getUserInfo(context);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _loadWalletOverview());
    }
    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.businessMode ==
        "single";

    super.initState();
  }

  Future<void> _loadWalletOverview() async {
    if (_walletOverviewLoading ||
        !Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      return;
    }
    setState(() {
      _walletOverviewLoading = true;
      _walletOverviewError = null;
    });
    try {
      final response =
          await di.sl<DioClient>().get('/api/v1/customer/wallet/overview');
      if (mounted) {
        setState(() => _walletOverview = AccountOverviewModel.fromJson(
            Map<String, dynamic>.from(response.data)));
      }
    } on DioException {
      if (mounted) {
        setState(() => _walletOverviewError =
            getTranslated('wallet_load_failed', context));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _walletOverviewError =
            getTranslated('wallet_load_failed', context));
      }
    } finally {
      if (mounted) setState(() => _walletOverviewLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // var authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      body: SigmaResponsiveContent(
          child: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: ProfileInfoSectionWidget()),
        SliverToBoxAdapter(
            child: Container(
          decoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          child: Consumer<AuthController>(builder: (ctx, authController, _) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall),
                      child: Center(child: MoreHorizontalSection())),
                  if (authController.isLoggedIn())
                    _AccountOverviewSection(
                      data: _walletOverview,
                      loading: _walletOverviewLoading,
                      error: _walletOverviewError,
                      onRetry: _loadWalletOverview,
                      onChanged: _loadWalletOverview,
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        0),
                    child: Text(getTranslated('general', context) ?? '',
                        style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(context).colorScheme.onSurface)),
                  ),
                  Consumer<SplashController>(
                      builder: (context, splashController, _) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Container(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: .05),
                                blurRadius: 1,
                                spreadRadius: 1,
                                offset: const Offset(0, 1))
                          ],
                          color: Provider.of<ThemeController>(context).darkTheme
                              ? Colors.white.withValues(alpha: .05)
                              : Theme.of(context).cardColor,
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: .20)),
                        ),
                        child: Column(children: [
                          MenuButtonWidget(
                            image: Images.trackOrderIcon,
                            title: getTranslated('TRACK_ORDER', context),
                            onTap: () {
                              RouterHelper.getGuestTrackOrderRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          if (authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.shoppingImage,
                              title: getTranslated('orders', context),
                              onTap: () => RouterHelper.getOrderScreenRoute(
                                  action: RouteAction.push,
                                  isBackButtonExist: true),
                            ),
                          if (authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.user,
                              title: getTranslated('profile', context),
                              onTap: () {
                                RouterHelper.getProfileScreen1Route(
                                    action: RouteAction.push);
                              },
                            ),
                          MenuButtonWidget(
                            image: Images.address,
                            title: getTranslated('addresses', context),
                            onTap: () {
                              RouterHelper.getAddressListScreen(
                                  action: RouteAction.push);
                            },
                          ),
                          MenuButtonWidget(
                            image: Images.coupon,
                            title: getTranslated('coupons', context),
                            onTap: () {
                              RouterHelper.getCouponListScreenRoute();
                            },
                          ),
                          if (authController.isLoggedIn())
                            if (splashController
                                    .configModel?.refEarningStatus ==
                                "1")
                              MenuButtonWidget(
                                image: Images.refIcon,
                                title: getTranslated('refer_and_earn', context),
                                isProfile: true,
                                onTap: () {
                                  RouterHelper.getReferAndEarnRoute(
                                      action: RouteAction.push);
                                },
                              ),
                          if (authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.restockIcon,
                              title: getTranslated('restock_requests', context),
                              onTap: () {
                                RouterHelper.getRestockListRoute(
                                    action: RouteAction.push);
                              },
                            ),
                          if (splashController.configModel!.activeTheme !=
                                  "default" &&
                              authController.isLoggedIn())
                            MenuButtonWidget(
                              image: Images.compare,
                              title: getTranslated('compare_products', context),
                              onTap: () {
                                RouterHelper.getCompareProductScreenRoute();
                              },
                            ),
                          MenuButtonWidget(
                            image: Images.notification,
                            title: getTranslated(
                              'notification',
                              context,
                            ),
                            isNotification: true,
                            onTap: () {
                              RouterHelper.getNotificationRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          MenuButtonWidget(
                            image: Images.settings,
                            title: getTranslated('settings', context),
                            onTap: () {
                              RouterHelper.getSettingsRoute(
                                  action: RouteAction.push);
                            },
                          ),
                          if (splashController
                                  .configModel?.blogUrl?.isNotEmpty ??
                              false)
                            MenuButtonWidget(
                                image: Images.blogIcon,
                                title: getTranslated('blog', context),
                                onTap: () {
                                  RouterHelper.getBlogScreenRoute(
                                      action: RouteAction.push,
                                      url: splashController
                                              .configModel?.blogUrl ??
                                          '');
                                }),
                        ]),
                      ),
                    );
                  }),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          0),
                      child: Text(
                          getTranslated('help_and_support', context) ?? '',
                          style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).colorScheme.onSurface))),
                  Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Container(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: .05),
                                    blurRadius: 1,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 1))
                              ],
                              color: Provider.of<ThemeController>(context)
                                      .darkTheme
                                  ? Colors.white.withValues(alpha: .05)
                                  : Theme.of(context).cardColor),
                          child: Consumer<SplashController>(
                              builder: (context, splashController, _) {
                            return Column(children: [
                              singleVendor
                                  ? const SizedBox()
                                  : MenuButtonWidget(
                                      image: Images.chats,
                                      title: getTranslated('inbox', context),
                                      onTap: () {
                                        RouterHelper.getInboxScreenRoute(
                                            action: RouteAction.push);
                                      },
                                    ),
                              MenuButtonWidget(
                                image: Images.callIcon,
                                title: getTranslated('contact_us', context),
                                onTap: () {
                                  RouterHelper.getContactUsScreenRoute();
                                },
                              ),
                              MenuButtonWidget(
                                image: Images.preference,
                                title: getTranslated('support_ticket', context),
                                onTap: () {
                                  RouterHelper.getSupportTicketRoute(
                                      action: RouteAction.push);
                                },
                              ),
                              if (splashController.defaultBusinessPages !=
                                      null &&
                                  splashController
                                      .defaultBusinessPages!.isNotEmpty) ...[
                                if (getPageBySlug(
                                        'refund-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'refund_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'refund-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'return-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'return_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'return-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'cancellation-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'cancellation_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'cancellation-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                                if (getPageBySlug(
                                        'shipping-policy',
                                        splashController
                                            .defaultBusinessPages) !=
                                    null)
                                  MenuButtonWidget(
                                      image: Images.termCondition,
                                      title: getTranslated(
                                          'shipping_policy', context),
                                      onTap: () =>
                                          RouterHelper.getHtmlViewRoute(
                                              page: getPageBySlug(
                                                  'shipping-policy',
                                                  splashController
                                                      .defaultBusinessPages)!)),
                              ],
                              MenuButtonWidget(
                                image: Images.faq,
                                title: getTranslated('faq', context),
                                onTap: () {
                                  RouterHelper.getFaqRoute(
                                      action: RouteAction.push);
                                },
                              ),
                              if (splashController.businessPages != null &&
                                  splashController.businessPages!.isNotEmpty)
                                ListView.builder(
                                    itemCount:
                                        splashController.businessPages?.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MenuButtonWidget(
                                        image: Images.termCondition,
                                        title: splashController
                                            .businessPages?[index].title,
                                        onTap: () {
                                          RouterHelper.getHtmlViewRoute(
                                              page: splashController
                                                  .businessPages![index]);
                                        },
                                      );
                                    })
                            ]);
                          }))),
                  if (getPageBySlug(
                              'terms-and-conditions',
                              Provider.of<SplashController>(context,
                                      listen: false)
                                  .defaultBusinessPages) !=
                          null ||
                      getPageBySlug(
                              'privacy-policy',
                              Provider.of<SplashController>(context,
                                      listen: false)
                                  .defaultBusinessPages) !=
                          null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeDefault,
                          0),
                      child: Text(
                          getTranslated('legal_and_privacy', context) ??
                              'Legal & Privacy',
                          style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Container(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Dimensions.fontSizeExtraSmall),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: .25)),
                          color: Provider.of<ThemeController>(context).darkTheme
                              ? Colors.white.withValues(alpha: .05)
                              : Theme.of(context).cardColor,
                        ),
                        child: Column(children: [
                          if (getPageBySlug(
                                  'terms-and-conditions',
                                  Provider.of<SplashController>(context,
                                          listen: false)
                                      .defaultBusinessPages) !=
                              null)
                            MenuButtonWidget(
                              image: Images.termCondition,
                              title: getTranslated('terms_condition', context),
                              onTap: () => RouterHelper.getHtmlViewRoute(
                                  page: getPageBySlug(
                                      'terms-and-conditions',
                                      Provider.of<SplashController>(context,
                                              listen: false)
                                          .defaultBusinessPages)!),
                            ),
                          if (getPageBySlug(
                                  'privacy-policy',
                                  Provider.of<SplashController>(context,
                                          listen: false)
                                      .defaultBusinessPages) !=
                              null)
                            MenuButtonWidget(
                              image: Images.privacyPolicy,
                              title: getTranslated('privacy_policy', context),
                              onTap: () => RouterHelper.getHtmlViewRoute(
                                  page: getPageBySlug(
                                      'privacy-policy',
                                      Provider.of<SplashController>(context,
                                              listen: false)
                                          .defaultBusinessPages)!),
                            ),
                          if (getPageBySlug(
                                  'about-us',
                                  Provider.of<SplashController>(context,
                                          listen: false)
                                      .defaultBusinessPages) !=
                              null)
                            MenuButtonWidget(
                              image: Images.aboutUs,
                              title: getTranslated('about_us', context),
                              onTap: () => RouterHelper.getHtmlViewRoute(
                                  page: getPageBySlug(
                                      'about-us',
                                      Provider.of<SplashController>(context,
                                              listen: false)
                                          .defaultBusinessPages)!),
                            ),
                        ]),
                      ),
                    ),
                  ],
                  ListTile(
                    leading: SizedBox(
                        width: 30,
                        child: Image.asset(
                          Images.logOut,
                          color: Theme.of(context).primaryColor,
                        )),
                    title: Text(
                        !authController.isLoggedIn()
                            ? getTranslated('sign_in', context)!
                            : getTranslated('sign_out', context)!,
                        style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    onTap: () {
                      if (!authController.isLoggedIn()) {
                        RouterHelper.getLoginRoute(
                            action: RouteAction.push,
                            fromPage:
                                '${RouterHelper.dashboardScreen}?page=more');
                      } else {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (_) =>
                                const LogoutCustomBottomSheetWidget());
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${getTranslated('version', context)} ${AppConstants.appVersion}',
                            style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).hintColor),
                          ),
                        ]),
                  ),
                ]);
          }),
        )),
      ])),
    );
  }

  BusinessPageModel? getPageBySlug(
      String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if (pagesList != null && pagesList.isNotEmpty) {
      for (var page in pagesList) {
        if (page.slug == slug) {
          pageModel = page;
        }
      }
    }
    return pageModel;
  }
}
