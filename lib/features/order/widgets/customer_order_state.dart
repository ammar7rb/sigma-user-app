import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/controllers/order_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/domain/models/support_ticket_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/screens/order_payment_retry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class CustomerOrderState extends StatelessWidget {
  final Orders order;
  const CustomerOrderState({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.customerFulfillmentStatus == null ||
        !['pending', 'confirmed', 'processing'].contains(order.orderStatus)) {
      return const SizedBox.shrink();
    }
    final reasons = order.customerPendingReasons;
    final preparing = order.customerFulfillmentStatus == 'preparing';
    const labels = {
      'order_payment_rejected': 'إعادة تقديم إثبات الدفع بعد رفضه',
      'order_payment_review': 'الدفع قيد التحقق',
      'account_activation': 'تفعيل الحساب',
      'monthly_subscription': 'دفع الاشتراك الشهري',
      'administrative_freeze': 'مراجعة القيود الإدارية',
      'outstanding_invoice': 'سداد الفاتورة المستحقة',
    };
    final message = preparing
        ? 'قيد التجهيز'
        : reasons.length == 1 && reasons.first == 'order_payment_review'
            ? 'الدفع قيد التحقق'
            : 'الطلب بانتظار ${reasons.map((e) => labels[e] ?? e).join(' و')}';
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(preparing ? Icons.inventory_2_outlined : Icons.schedule_rounded,
              color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w600)))
        ]),
        if (reasons.contains('order_payment_rejected') && order.id != null)
          TextButton.icon(
              onPressed: () async {
                final submitted = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => OrderPaymentRetryScreen(
                            orderId: order.id!,
                            amount: order.orderAmount ?? 0)));
                if (submitted == true && context.mounted) {
                  await context
                      .read<OrderDetailsController>()
                      .getOrderFromOrderId(order.id.toString());
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'الدفع قيد المراجعة. حدّث تفاصيل الطلب لمتابعة الحالة.')));
                }
              },
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('إعادة تقديم إثبات الدفع')),
        if (reasons.contains('account_activation'))
          TextButton.icon(
              onPressed: () {
                final activation =
                    context.read<ProfileController>().userInfoModel?.activation;
                if (activation?.ticketId != null) {
                  RouterHelper.getSupportConversationRoute(
                      action: RouteAction.push,
                      supportTicketModel: SupportTicketModel(
                          id: activation!.ticketId,
                          subject: 'تفعيل الحساب',
                          purpose: 'account_activation',
                          status: activation.ticketStatus ?? 'pending'));
                } else {
                  RouterHelper.getSupportTicketRoute(action: RouteAction.push);
                }
              },
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text('تواصل لتفعيل الحساب')),
        if (reasons.contains('monthly_subscription'))
          TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const MonthlySubscriptionScreen())),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('الاشتراك الشهري')),
      ]),
    );
  }
}
