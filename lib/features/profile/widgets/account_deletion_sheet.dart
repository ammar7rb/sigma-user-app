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
  bool confirmed = false;
  int stage = 1;
  String? flowToken;
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  bool get arabic =>
      Provider.of<LocalizationController>(context, listen: false)
          .locale
          .languageCode ==
      'ar';

  Future<void> submit() async {
    if (busy || input.text.trim().isEmpty || (stage == 3 && !confirmed)) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final step =
          switch (stage) { 1 => 'begin', 2 => 'reason', _ => 'finish' };
      final response = await di.sl<DioClient>().post(
        '/api/v1/customer/account-deletion/$step',
        data: {
          if (stage > 1) 'flow_token': flowToken,
          if (stage == 2)
            'reason': input.text.trim()
          else
            'password': input.text,
          if (stage == 3) 'confirmation': confirmed,
        },
      );
      final data = response.data;
      if (!mounted) return;
      if (stage < 3) {
        if (data is! Map ||
            data['stage'] != stage + 1 ||
            (stage == 1 && data['flow_token'] is! String)) {
          throw StateError('Invalid deletion step');
        }
        if (stage == 1) flowToken = data['flow_token'] as String;
        input.clear();
        setState(() => stage++);
        return;
      }
      if (data is! Map || data['deleted'] != true) {
        throw StateError('Deletion was not confirmed');
      }
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
            TextField(
              key: ValueKey(stage),
              controller: input,
              enabled: !busy,
              obscureText: stage != 2,
              maxLines: stage == 2 ? 4 : 1,
              maxLength: stage == 2 ? 5000 : 128,
              decoration: InputDecoration(
                labelText: stage == 2
                    ? (isArabic
                        ? 'سبب الحذف (150 حرفًا على الأقل)'
                        : 'Reason (at least 150 characters)')
                    : (isArabic ? 'كلمة المرور الحالية' : 'Current password'),
              ),
            ),
            if (stage == 3)
              CheckboxListTile(
                value: confirmed,
                onChanged: busy
                    ? null
                    : (value) => setState(() => confirmed = value == true),
                title: Text(isArabic
                    ? 'أؤكد إغلاق حسابي'
                    : 'I confirm closing my account'),
              ),
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
                onPressed: busy || (stage == 3 && !confirmed) ? null : submit,
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(stage == 3
                        ? (isArabic ? 'حذف الحساب' : 'Delete account')
                        : (isArabic ? 'متابعة' : 'Continue'))),
            TextButton(
                onPressed: busy ? null : () => Navigator.pop(context),
                child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          ]),
    ));
  }
}
