import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

class TransferRecipientDetail {
  final String label;
  final String value;

  const TransferRecipientDetail(this.label, this.value);
}

/// Displays only the recipient details attached to the selected method.
class TransferRecipientCard extends StatelessWidget {
  final String channel;
  final List<TransferRecipientDetail> details;

  const TransferRecipientCard({
    super.key,
    required this.channel,
    required this.details,
  });

  String _detailLabel(BuildContext context, String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized.contains('name') || normalized.contains('اسم')) {
      return getTranslated('transfer_recipient_name', context) ?? label;
    }
    if (normalized.contains('number') ||
        normalized.contains('phone') ||
        normalized.contains('account') ||
        normalized.contains('wallet') ||
        normalized.contains('instapay') ||
        normalized.contains('رقم') ||
        normalized.contains('محفظة') ||
        normalized.contains('حساب')) {
      return getTranslated(
            channel == 'instapay'
                ? 'transfer_recipient_instapay'
                : 'transfer_recipient_wallet',
            context,
          ) ??
          label;
    }
    return label.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isInstaPay = channel == 'instapay';
    final title = getTranslated(
          isInstaPay ? 'instapay_payment' : 'electronic_wallet_payment',
          context,
        ) ??
        '';
    final instruction = getTranslated(
          isInstaPay
              ? 'instapay_transfer_instructions'
              : 'wallet_transfer_instructions',
          context,
        ) ??
        '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: .24)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
            isInstaPay
                ? Icons.account_balance_rounded
                : Icons.account_balance_wallet_outlined,
            color: colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: colors.onSurface)),
          ),
        ]),
        const SizedBox(height: 12),
        for (final detail
            in details.where((item) => item.value.trim().isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_detailLabel(context, detail.label),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  SelectableText(detail.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface)),
                ],
              ),
            ),
          ),
        Text(instruction,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.onSurface, height: 1.45)),
      ]),
    );
  }
}
