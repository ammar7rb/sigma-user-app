import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class DeleteAccountBottomSheet extends StatefulWidget {
  final String customerId;
  const DeleteAccountBottomSheet({super.key, required this.customerId});
  @override
  State<DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState extends State<DeleteAccountBottomSheet> {
  final password = TextEditingController();
  final reason = TextEditingController();
  int stage = 1;
  String? token;
  String? error;
  bool busy = false;
  @override
  void dispose() {
    password.dispose();
    reason.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || (stage == 2 && reason.text.trim().runes.length < 150)) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final endpoint = {1: 'begin', 2: 'reason', 3: 'finish'}[stage];
      final response = await di
          .sl<DioClient>()
          .post('/api/v1/customer/account-deletion/$endpoint', data: {
        if (stage != 2) 'password': password.text,
        if (stage != 1) 'flow_token': token,
        if (stage == 2) 'reason': reason.text.trim(),
      });
      password.clear();
      if (!mounted) return;
      if (stage == 3) {
        await Provider.of<AuthController>(context, listen: false)
            .clearSharedData();
        if (mounted) {
          RouterHelper.getLoginRoute(
              action: RouteAction.pushNamedAndRemoveUntil);
        }
      } else {
        setState(() {
          if (stage == 1) token = response.data['flow_token'];
          stage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final body = e is DioException ? e.response?.data : null;
          error = body is Map && body['errors'] is Map
              ? '${(body['errors'] as Map).values.first.first}'
              : 'تعذر إتمام الخطوة. تحقق من الاتصال وأعد المحاولة.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('حذف الحساب',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('الخطوة $stage من 3'),
              const SizedBox(height: 20),
              if (error != null)
                Semantics(
                    liveRegion: true,
                    child: Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              if (stage == 3)
                const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                        'حذف الحساب نهائي ولا يمكن التراجع عنه. تحتفظ الإدارة بهويتك وسجلك المالي، مع وسم الحساب بأنه محذوف.')),
              if (stage == 2) ...[
                TextField(
                    controller: reason,
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 5000,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        labelText: 'سبب حذف الحساب',
                        helperText:
                            '150 حرفًا على الأقل بعد إزالة المسافات الطرفية')),
                Text(
                    '${reason.text.trim().runes.length} / 150 حرفًا على الأقل'),
              ] else
                TextField(
                    controller: password,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                        labelText: stage == 1
                            ? 'كلمة المرور الحالية'
                            : 'كلمة المرور للتأكيد النهائي')),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: busy ||
                          (stage == 2 && reason.text.trim().runes.length < 150)
                      ? null
                      : submit,
                  style: stage == 3
                      ? FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError)
                      : null,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator())
                      : Text(stage == 3 ? 'حذف الحساب نهائيًا' : 'متابعة')),
              TextButton(
                  onPressed: busy ? null : () => Navigator.pop(context),
                  child: const Text('إلغاء')),
            ]),
      ));
}
