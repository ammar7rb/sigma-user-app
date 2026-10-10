import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _copyable(String label) =>
      !RegExp(r'name|owner|holder|اسم|صاحب', caseSensitive: false)
          .hasMatch(label) &&
      RegExp(r'number|phone|mobile|account|wallet|instapay|address|رقم|محفظ|حساب|عنوان',
              caseSensitive: false)
          .hasMatch(label);

  String _detailLabel(BuildContext context, String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized.contains('name') || normalized.contains('اسم')) {
      final translated = getTranslated('transfer_recipient_name', context);
      return translated == null || translated == 'transfer_recipient_name'
          ? 'اسم صاحب الحساب'
          : translated;
    }
    if (normalized.contains('number') ||
        normalized.contains('phone') ||
        normalized.contains('account') ||
        normalized.contains('wallet') ||
        normalized.contains('instapay') ||
        normalized.contains('رقم') ||
        normalized.contains('محفظة') ||
        normalized.contains('حساب')) {
      return channel == 'instapay' ? 'رقم التحويل البنكي' : 'رقم المحفظة';
    }
    return label.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isInstaPay = channel == 'instapay';
    final accent = Theme.of(context).brightness == Brightness.dark
        ? (isInstaPay ? const Color(0xFFD0B5FF) : const Color(0xFFFFB4B9))
        : (isInstaPay ? const Color(0xFF6625AE) : const Color(0xFFA92332));
    final translatedTitle = getTranslated(
          isInstaPay ? 'instapay_payment' : 'electronic_wallet_payment',
          context,
        ) ??
        '';

    final title = translatedTitle == 'instapay_payment' ||
            translatedTitle == 'electronic_wallet_payment' ||
            translatedTitle.isEmpty
        ? (isInstaPay ? 'InstaPay' : 'المحفظة الإلكترونية')
        : translatedTitle;
    final instructionKey = isInstaPay
        ? 'instapay_transfer_instructions'
        : 'wallet_transfer_instructions';
    final translatedInstruction = getTranslated(instructionKey, context);
    final instruction =
        translatedInstruction == null || translatedInstruction == instructionKey
            ? 'قم بالتحويل وأرفق صورة لإثبات الدفع.'
            : translatedInstruction;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .24)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
            isInstaPay
                ? Icons.account_balance_rounded
                : Icons.account_balance_wallet_outlined,
            color: accent,
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
                  Row(children: [
                    Expanded(
                        child: Text(detail.value,
                            textDirection: _copyable(detail.label)
                                ? TextDirection.ltr
                                : null,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface))),
                    if (_copyable(detail.label))
                      IconButton(
                          tooltip: 'نسخ الرقم',
                          icon: Icon(Icons.copy_rounded, color: accent),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: detail.value));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم نسخ الرقم')));
                            }
                          }),
                  ]),
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
