import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/widgets/customer_activation_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/subscription_expiry_banner.dart';

class CustomerAccountNotices extends StatefulWidget {
  final Widget child;
  final VoidCallback onRenew;
  const CustomerAccountNotices(
      {super.key, required this.child, required this.onRenew});
  @override
  State<CustomerAccountNotices> createState() => _CustomerAccountNoticesState();
}

class _CustomerAccountNoticesState extends State<CustomerAccountNotices>
    with WidgetsBindingObserver {
  Timer? timer;
  bool refreshing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(const Duration(minutes: 1), (_) => refresh());
  }

  Future<void> refresh() async {
    if (!mounted ||
        refreshing ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        !context.read<AuthController>().isLoggedIn()) {
      return;
    }
    refreshing = true;
    try {
      await context.read<ProfileController>().getUserInfo(context);
    } catch (_) {
      /* Keep browsing available during a connection failure. */
    } finally {
      refreshing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<AuthController>().isLoggedIn();
    final profile = context.watch<ProfileController>().userInfoModel;
    final activation = loggedIn ? profile?.activation : null;
    final subscription = profile?.purchaseEligibility?['subscription'];
    if (!loggedIn) return widget.child;
    final visible = (activation != null && !activation.isActive) ||
        (subscription is Map && subscription['status'] == 'expired');
    if (!visible) return widget.child;
    return Column(children: [
      SafeArea(
          bottom: false,
          child: Column(children: [
            if (activation != null && !activation.isActive)
              CustomerActivationBannerWidget(activation: activation),
            SubscriptionExpiryBanner(
                subscription: subscription, onRenew: widget.onRenew),
          ])),
      Expanded(child: widget.child),
    ]);
  }
}
