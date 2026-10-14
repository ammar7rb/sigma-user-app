import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';

class DeleteAccountBottomSheet extends StatefulWidget {
  final String customerId;
  const DeleteAccountBottomSheet({super.key, required this.customerId});
  @override
  State<DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState extends State<DeleteAccountBottomSheet> {
  String? error;
  bool busy = false;
  bool get arabic =>
      Provider.of<LocalizationController>(context, listen: false)
          .locale
          .languageCode ==
      'ar';

  Future<void> submit() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await di.sl<DioClient>().post(
          '/api/v1/customer/account-deletion/confirm',
          data: {'confirmation': true});
      if (response.data is! Map || response.data['deleted'] != true) {
        throw StateError('Deletion was not confirmed');
      }
      if (!mounted) return;
      await Provider.of<AuthController>(context, listen: false)
          .clearSharedData();
      if (mounted) {
        RouterHelper.getLoginRoute(action: RouteAction.pushNamedAndRemoveUntil);
      }
    } catch (e) {
      if (mounted) {
        final body = e is DioException ? e.response?.data : null;
        String? message;
        if (body is Map && body['errors'] is Map) {
          final errors = body['errors'] as Map;
          if (errors.isNotEmpty) {
            final first = errors.values.first;
            message =
                first is List && first.isNotEmpty ? '${first.first}' : '$first';
          }
        }
        setState(() => error = message ??
            (arabic
                ? 'تعذر حذف الحساب. تحقق من الاتصال وأعد المحاولة.'
                : 'Could not delete your account. Check your connection and try again.'));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LocalizationController>().locale.languageCode == 'ar';
    return SafeArea(
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isArabic ? 'حذف الحساب' : 'Delete account',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(isArabic
                ? 'هل أنت متأكد من حذف حسابك؟ بعد التأكيد سيتم إغلاق الحساب وتسجيل خروجك.'
                : 'Are you sure you want to delete your account? Confirming will close your account and sign you out.'),
            if (error != null)
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Semantics(
                      liveRegion: true,
                      child: Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)))),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: busy ? null : submit,
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        isArabic ? 'نعم، حذف الحساب' : 'Yes, delete account')),
            TextButton(
                onPressed: busy ? null : () => Navigator.pop(context),
                child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          ]),
    ));
  }
}
