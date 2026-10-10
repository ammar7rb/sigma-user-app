import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';

class SubscriptionExpiryBanner extends StatelessWidget {
  final dynamic subscription;
  final VoidCallback? onRenew;
  const SubscriptionExpiryBanner({super.key, this.subscription, this.onRenew});

  @override
  Widget build(BuildContext context) {
    if (subscription is! Map || subscription['status'] != 'expired') {
      return const SizedBox.shrink();
    }
    return Material(
      color: const Color(0xFFFFE9BA),
      child: InkWell(
        onTap: onRenew ??
            () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const MonthlySubscriptionScreen(),
                )),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(Icons.event_repeat_rounded, color: Color(0xFF694300)),
            SizedBox(width: 12),
            Expanded(
                child: Text(
                    'انتهى اشتراكك الشهري. جدّد الاشتراك للمتابعة إلى الشراء.',
                    style: TextStyle(
                        color: Color(0xFF694300),
                        fontWeight: FontWeight.w600))),
            SizedBox(width: 8),
            Icon(Icons.chevron_left_rounded, color: Color(0xFF694300)),
          ]),
        ),
      ),
    );
  }
}
