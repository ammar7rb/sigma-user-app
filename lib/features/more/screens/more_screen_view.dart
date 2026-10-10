import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/sigma_responsive_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/screens/pending_post_purchase_invoices_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/domain/models/account_overview_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/screens/customer_wallet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/profile_info_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/more_horizontal_section_widget.dart';
import 'package:provider/provider.dart';

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
                      title: 'الاشتراك الشهري',
                      value: data!.subscriptionActive
                          ? 'متبقي ${data!.subscriptionRemainingDays} يومًا'
                          : 'اشترك أو جدّد',
                      icon: Icons.calendar_month_outlined,
                      color: const Color(0xFF14A673),
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const MonthlySubscriptionScreen(),
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
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF3A2B19)
                            : const Color(0xFFFFF3D9))
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
    final auth = context.watch<AuthController>();
    final arabic = Directionality.of(context) == TextDirection.rtl;
    Widget menu(IconData icon, String ar, String en, VoidCallback action) =>
        ListTile(
            leading: Icon(icon, color: Theme.of(context).primaryColor),
            title: Text(arabic ? ar : en),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: action);
    return Scaffold(
        body: SigmaResponsiveContent(
            child: RefreshIndicator(
                onRefresh: _loadWalletOverview,
                child: ListView(children: [
                  const ProfileInfoSectionWidget(),
                  const MoreHorizontalSection(),
                  if (auth.isLoggedIn()) ...[
                    _AccountOverviewSection(
                        data: _walletOverview,
                        loading: _walletOverviewLoading,
                        error: _walletOverviewError,
                        onRetry: _loadWalletOverview,
                        onChanged: _loadWalletOverview),
                    menu(
                        Icons.person_outline,
                        'الملف الشخصي',
                        'Profile',
                        () => RouterHelper.getProfileScreen1Route(
                            action: RouteAction.push)),
                    menu(
                        Icons.location_on_outlined,
                        'العناوين المحفوظة',
                        'Saved addresses',
                        () => RouterHelper.getAddressListScreen(
                            action: RouteAction.push)),
                    menu(
                        Icons.receipt_long_outlined,
                        'الطلبات السابقة',
                        'Order history',
                        () => RouterHelper.getOrderScreenRoute(
                            action: RouteAction.push, isBackButtonExist: true)),
                    menu(
                        Icons.pending_actions,
                        'الطلبات المعلقة',
                        'Pending orders',
                        () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                const PendingPostPurchaseInvoicesScreen()))),
                    menu(
                        Icons.support_agent,
                        'المساعدة والدعم',
                        'Help & support',
                        () => RouterHelper.getSupportTicketRoute(
                            action: RouteAction.push)),
                  ],
                  menu(
                      Icons.lock_reset,
                      'نسيت كلمة المرور؟',
                      'Forgot password?',
                      () => RouterHelper.getForgetPasswordScreenRoute(
                          action: RouteAction.push)),
                  menu(
                      Icons.logout,
                      auth.isLoggedIn() ? 'تسجيل الخروج' : 'تسجيل الدخول',
                      auth.isLoggedIn() ? 'Sign out' : 'Sign in', () {
                    if (!auth.isLoggedIn()) {
                      RouterHelper.getLoginRoute(action: RouteAction.push);
                    } else {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              const LogoutCustomBottomSheetWidget());
                    }
                  }),
                  const SizedBox(height: 24),
                ]))));
  }
}
