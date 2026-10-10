import 'package:flutter/material.dart';

/// Selection never debits a balance. The caller confirms and submits the chosen method.
class SubscriptionPaymentChoices extends StatelessWidget {
  final String amount;
  final bool walletEnabled;
  final List<Map<String, dynamic>> methods;
  final ValueChanged<String> onSelected;
  const SubscriptionPaymentChoices(
      {super.key,
      required this.amount,
      required this.walletEnabled,
      required this.methods,
      required this.onSelected});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
          child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              children: [
                Row(children: [
                  Expanded(
                      child: Text('اختر طريقة الدفع',
                          style: Theme.of(context).textTheme.titleLarge)),
                  IconButton(
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ]),
                Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text('المبلغ المطلوب: $amount')),
                if (walletEnabled)
                  _choice(
                      context,
                      'wallet',
                      'محفظة المشتريات',
                      'الدفع من رصيدك المتاح',
                      Icons.account_balance_wallet_outlined,
                      Theme.of(context).colorScheme.primary),
                for (final method in methods)
                  _choice(
                      context,
                      '${method['id']}',
                      method['payment_channel'] == 'instapay'
                          ? 'InstaPay'
                          : 'محفظة إلكترونية',
                      '${method['method_name']}',
                      method['payment_channel'] == 'instapay'
                          ? Icons.swap_horiz_rounded
                          : Icons.phone_android_rounded,
                      method['payment_channel'] == 'instapay'
                          ? const Color(0xff8d55cf)
                          : const Color(0xffd34b5c)),
                if (!walletEnabled && methods.isEmpty)
                  const Text(
                      'لا توجد وسيلة دفع متاحة حاليًا. تواصل مع الإدارة.'),
              ]),
        ),
      );

  Widget _choice(BuildContext context, String id, String title, String subtitle,
          IconData icon, Color color) =>
      Column(children: [
        ListTile(
          key: ValueKey('payment-choice-$id'),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Icon(icon, color: color, size: 28),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_left),
          onTap: () => onSelected(id),
        ),
        const Divider(height: 1)
      ]);
}
