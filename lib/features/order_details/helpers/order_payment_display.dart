import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/domain/models/order_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

class OrderPaymentDisplay {
  static String _text(BuildContext context, String key) =>
      getTranslated(key, context) ?? key;

  static bool isSubmittedTransfer(String? method, OfflinePayments? details) =>
      method == 'offline_payment' && details != null;

  static String status(BuildContext context, String? status,
      String? method, OfflinePayments? details) {
    if (isSubmittedTransfer(method, details)) return _text(context, 'paid');
    if (status == null || status.isEmpty) return '';
    return _text(context, status);
  }

  static String method(BuildContext context, String? rawMethod,
      OfflinePayments? details) {
    if (rawMethod == 'offline_payment' && details != null) {
      return transferMethod(context, details.paymentInfo['method_name']);
    }
    if (rawMethod == null || rawMethod.isEmpty) return '';
    final translated = _text(context, rawMethod);
    return translated == rawMethod
        ? rawMethod.replaceAll('_', ' ')
        : translated;
  }

  static String transferMethod(BuildContext context, Object? rawName) {
    final name = rawName?.toString().trim() ?? '';
    final normalized = name.toLowerCase();
    if (normalized.contains('instapay') ||
        normalized.contains('انستا') ||
        normalized.contains('إنستا')) {
      return _text(context, 'instapay_payment');
    }
    if (normalized.contains('wallet') || normalized.contains('محفظ')) {
      return _text(context, 'electronic_wallet_payment');
    }
    return name.isNotEmpty ? name : _text(context, 'offline_payment');
  }

  static String detailLabel(BuildContext context, String key,
      {Object? methodName}) {
    final normalized = key.trim().toLowerCase();
    final isInstaPay = methodName?.toString().toLowerCase().contains('instapay') ?? false;
    final translationKey = switch (normalized) {
      'method_name' => 'payment_method',
      'sender_name' => 'transfer_sender_full_name',
      'sender_identifier' || 'sender_wallet_or_phone' => isInstaPay
          ? 'transfer_sender_instapay'
          : 'transfer_sender_wallet',
      'payment_proof' || 'payment_screenshot' => 'payment_screenshot',
      _ => normalized,
    };
    final translated = _text(context, translationKey);
    return translated == translationKey
        ? key.replaceAll('_', ' ')
        : translated;
  }

  static String detailValue(BuildContext context, String key, Object? value) {
    if (key == 'method_name') return transferMethod(context, value);
    if (value is Map || value is List) {
      return _text(context, 'payment_proof_uploaded');
    }
    return value?.toString() ?? '';
  }
}
