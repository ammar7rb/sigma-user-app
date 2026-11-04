import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/controllers/order_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/screens/order_payment_retry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';

class CustomerOrderState extends StatelessWidget {
  final Orders order;
  const CustomerOrderState({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.orderStatus == 'delivered') {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(Icons.check_circle, color: Colors.green.shade700), const SizedBox(width: 10), Text('تم التسليم', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))]),
      );
    }
    final refund = order.purchaseEligibility?['package_refund'];
    if (refund is Map) {
      final complete = refund['status'] == 'completed';
      return Padding(padding: const EdgeInsets.all(16), child: Text(complete
          ? 'تم تسجيل رد المبلغ.'
          : 'طلب رد المبلغ قيد مراجعة الإدارة خلال ١٥ إلى ٣٠ يومًا من تاريخ طلب الإلغاء.'));
    }
    if (order.customerFulfillmentStatus == null ||
        !['pending', 'confirmed', 'processing'].contains(order.orderStatus)) {
      return const SizedBox.shrink();
    }
    final reasons = order.customerPendingReasons
        .where((reason) => reason != 'account_activation')
        .toList();
    final preparing =
        reasons.isEmpty || order.customerFulfillmentStatus == 'preparing';
    const labels = {
      'order_payment_rejected': 'إعادة تقديم إثبات الدفع بعد رفضه',
      'order_payment_review': 'الدفع قيد التحقق',
      'monthly_subscription': 'اختيار باقة لاستكمال الطلب',
      'administrative_freeze': 'مراجعة القيود الإدارية',
      'outstanding_invoice': 'سداد الفاتورة المستحقة',
    };
    final message = (order.purchaseEligibility?['message'] as String?) ?? (preparing
        ? 'قيد التجهيز'
        : reasons.length == 1 && reasons.first == 'order_payment_review'
            ? 'الدفع قيد التحقق'
            : 'الطلب بانتظار ${reasons.map((e) => labels[e] ?? e).join(' و')}');
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
        if (order.purchaseEligibility?['can_cancel_for_package'] == true && order.id != null)
          TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
                  title: const Text('إلغاء الطلب'),
                  content: const Text('سيُلغى الطلب ويُطلب رد ثمن المشتريات والشحن المدفوع خلال ١٥ إلى ٣٠ يومًا من تاريخ الإلغاء.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('تراجع')),
                    TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('تأكيد الإلغاء'))]));
                if (confirm != true || !context.mounted) return;
                try {
                  await di.sl<DioClient>().dio!.post('/api/v1/customer/order/${order.id}/package-cancellation');
                  if (!context.mounted) return;
                  await context.read<OrderDetailsController>().getOrderFromOrderId(order.id.toString());
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب إلغاء الطلب ورد المبلغ.')));
                } catch (_) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر إلغاء الطلب. حدّث الصفحة أو تواصل مع الدعم.')));
                }
              }, icon: const Icon(Icons.cancel_outlined), label: const Text('إلغاء الطلب وطلب رد المبلغ')),
        if (order.purchaseEligibility?['next_action'] == 'choose_package')
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
