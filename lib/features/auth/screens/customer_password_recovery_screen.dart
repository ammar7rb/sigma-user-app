import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

class CustomerPasswordRecoveryScreen extends StatefulWidget {
  final bool changeRequired;
  final FlutterSecureStorage storage;
  const CustomerPasswordRecoveryScreen(
      {super.key,
      this.changeRequired = false,
      this.storage = const FlutterSecureStorage()});
  @override
  State<CustomerPasswordRecoveryScreen> createState() =>
      _CustomerPasswordRecoveryScreenState();
}

class _CustomerPasswordRecoveryScreenState
    extends State<CustomerPasswordRecoveryScreen> {
  final form = GlobalKey<FormState>();
  final identity = TextEditingController(),
      current = TextEditingController(),
      password = TextEditingController(),
      confirmation = TextEditingController();
  bool busy = false;
  String? message;
  String? supportToken;
  List<Map<String, dynamic>> messages = [];
  bool conversationCreated = false;
  final reply = TextEditingController();
  Timer? chatRefresh;
  static const storageKey = 'customer_password_recovery_conversation';
  @override
  void initState() {
    super.initState();
    if (!widget.changeRequired) {
      prepareConversation();
      chatRefresh = Timer.periodic(const Duration(seconds: 15), (_) {
        if (conversationCreated) loadConversation();
      });
    }
  }

  Future<void> prepareConversation() async {
    try {
      var token = await widget.storage.read(key: storageKey);
      if (token == null) {
        final random = Random.secure();
        token = List.generate(32,
                (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
            .join();
        await widget.storage.write(key: storageKey, value: token);
      }
      if (mounted) {
        setState(() => supportToken = token);
        await loadConversation();
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => message = 'تعذر حفظ الوصول إلى محادثة الدعم. أعد المحاولة.');
      }
    }
  }

  Future<void> loadConversation() async {
    if (supportToken == null) return;
    try {
      final response = await di.sl<DioClient>().get(
          '/api/v1/customer/password-recovery/conversation',
          options: Options(headers: {'X-Support-Token': supportToken}));
      if (mounted) {
        setState(() {
          messages =
              List<Map<String, dynamic>>.from(response.data['messages'] ?? []);
          conversationCreated = true;
        });
      }
    } catch (_) {/* A new token has no conversation until its first request. */}
  }

  Future<void> sendReply() async {
    if (reply.text.trim().isEmpty || busy) return;
    setState(() => busy = true);
    try {
      await di.sl<DioClient>().post(
          '/api/v1/customer/password-recovery/conversation',
          data: {'message': reply.text.trim()},
          options: Options(headers: {'X-Support-Token': supportToken}));
      reply.clear();
      await loadConversation();
    } catch (_) {
      if (mounted) setState(() => message = 'تعذر إرسال الرد. أعد المحاولة.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    chatRefresh?.cancel();
    reply.dispose();
    identity.dispose();
    current.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate() || busy) return;
    if (!widget.changeRequired && supportToken == null) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final response = await di.sl<DioClient>().post(
          widget.changeRequired
              ? '/api/v1/customer/password-recovery/change'
              : '/api/v1/customer/password-recovery/request',
          data: widget.changeRequired
              ? {
                  'current_password': current.text,
                  'password': password.text,
                  'password_confirmation': confirmation.text
                }
              : {'identity': identity.text.trim()},
          options: widget.changeRequired
              ? null
              : Options(headers: {'X-Support-Token': supportToken}));
      if (!mounted) return;
      if (widget.changeRequired) {
        final auth = context.read<AuthController>();
        await auth.clearSharedData();
        auth.setPasswordChangeRequired(false);
        if (mounted) {
          RouterHelper.getLoginRoute(action: RouteAction.pushReplacement);
        }
      } else {
        setState(() => message = '${response.data['message']}');
        await loadConversation();
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = widget.changeRequired
            ? 'تعذر تغيير الكلمة. تحقق من الكلمة المؤقتة وصلاحيتها وكلمة المرور الجديدة.'
            : 'تعذر إرسال الطلب. تحقق من الاتصال وأعد المحاولة.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !widget.changeRequired,
      child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: !widget.changeRequired,
              title: Text(widget.changeRequired
                  ? 'تغيير الكلمة المؤقتة'
                  : 'استعادة كلمة المرور')),
          body: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                      key: form,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(widget.changeRequired
                                ? 'اختر كلمة مرور جديدة قبل متابعة استخدام الحساب. بعد الحفظ سجّل الدخول بالكلمة الجديدة.'
                                : 'أدخل الموبايل أو البريد المسجل. ستتحقق الإدارة من صاحب الحساب ثم ترسل كلمة مؤقتة في محادثة الدعم هنا.'),
                            const SizedBox(height: 24),
                            if (!widget.changeRequired)
                              TextFormField(
                                  controller: identity,
                                  decoration: const InputDecoration(
                                      labelText: 'الموبايل أو البريد المسجل'),
                                  autofillHints: const [AutofillHints.username],
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? 'أدخل الموبايل أو البريد'
                                      : null),
                            if (widget.changeRequired) ...[
                              TextFormField(
                                  controller: current,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'الكلمة المؤقتة'),
                                  autofillHints: const [AutofillHints.password],
                                  validator: (v) => (v ?? '').isEmpty
                                      ? 'أدخل الكلمة المؤقتة'
                                      : null),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'كلمة المرور الجديدة'),
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  validator: (v) => (v ?? '').length < 8
                                      ? 'استخدم 8 أحرف على الأقل'
                                      : null),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: confirmation,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'تأكيد كلمة المرور الجديدة'),
                                  validator: (v) => v != password.text
                                      ? 'الكلمتان غير متطابقتين'
                                      : null)
                            ],
                            if (message != null)
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(message!)),
                            const SizedBox(height: 24),
                            FilledButton(
                                onPressed: busy ||
                                        (!widget.changeRequired &&
                                            supportToken == null)
                                    ? null
                                    : submit,
                                child: Text(busy
                                    ? 'جارٍ الحفظ…'
                                    : widget.changeRequired
                                        ? 'حفظ كلمة المرور الجديدة'
                                        : 'إرسال طلب للإدارة')),
                            if (!widget.changeRequired &&
                                conversationCreated) ...[
                              const SizedBox(height: 24),
                              Text('محادثة الدعم الفني',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              for (final item in messages)
                                Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              item['sender'] == 'admin'
                                                  ? 'الإدارة'
                                                  : 'أنت',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text('${item['body']}')
                                        ])),
                              TextField(
                                  controller: reply,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                      labelText: 'رد على الإدارة')),
                              FilledButton(
                                  onPressed: busy ? null : sendReply,
                                  child: const Text('إرسال الرد')),
                              TextButton(
                                  onPressed: loadConversation,
                                  child: const Text('تحديث المحادثة')),
                            ],
                            if (widget.changeRequired)
                              TextButton(
                                  onPressed: () {
                                    context
                                        .read<AuthController>()
                                        .clearSharedData();
                                    context
                                        .read<AuthController>()
                                        .setPasswordChangeRequired(false);
                                    RouterHelper.getLoginRoute(
                                        action: RouteAction.pushReplacement);
                                  },
                                  child: const Text('تسجيل الخروج'))
                          ]))))));
}
