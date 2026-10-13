import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';

class CustomerContactPhones extends StatefulWidget {
  const CustomerContactPhones({super.key});
  @override
  State<CustomerContactPhones> createState() => _CustomerContactPhonesState();
}

class _CustomerContactPhonesState extends State<CustomerContactPhones> {
  final List<TextEditingController> phones = [];
  bool loading = true, busy = false;
  String? error, message;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final phone in phones) {
      phone.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final response =
          await di.sl<DioClient>().get('/api/v1/customer/contact-phones');
      if (!mounted) return;
      setState(() {
        for (final phone in phones) {
          phone.dispose();
        }
        phones.clear();
        phones.addAll((response.data['phones'] as List)
            .map((value) => TextEditingController(text: '$value')));
        loading = false;
        error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'تعذر تحميل أرقام التواصل.';
        });
      }
    }
  }

  Future<void> save() async {
    if (busy) return;
    final values = phones
        .map((phone) => EgyptPhoneHelper.normalizeLocal(phone.text))
        .toList();
    if (values.any((value) => !EgyptPhoneHelper.isValidLocal(value)) ||
        values.toSet().length != values.length) {
      setState(() => error = 'أدخل أرقام موبايل مصرية صحيحة وغير مكررة.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      await di
          .sl<DioClient>()
          .put('/api/v1/customer/contact-phones', data: {'phones': values});
      if (mounted) setState(() => message = 'تم حفظ أرقام التواصل.');
    } catch (e) {
      if (mounted) {
        setState(() {
          final body = e is DioException ? e.response?.data : null;
          final errors = body is Map ? body['errors'] : null;
          error = errors is Map && errors.isNotEmpty
              ? '${(errors.values.first as List).first}'
              : 'تعذر حفظ الأرقام. أعد المحاولة.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('أرقام التواصل الإضافية',
            style: Theme.of(context).textTheme.titleMedium),
        const Text('هذه الأرقام للتواصل. تسجيل الدخول يستخدم الرقم الأساسي.'),
        if (loading) const LinearProgressIndicator(),
        if (error != null)
          Text(error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        if (message != null) Text(message!),
        for (final phone in phones)
          Row(children: [
            Expanded(
                child: TextField(
                    controller: phone,
                    enabled: !busy,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    maxLength: 20,
                    decoration: const InputDecoration(
                        labelText: 'رقم تواصل إضافي', counterText: ''))),
            IconButton(
                tooltip: 'إزالة الرقم',
                onPressed: busy
                    ? null
                    : () => setState(() {
                          phones.remove(phone);
                          phone.dispose();
                        }),
                icon: const Icon(Icons.remove_circle_outline))
          ]),
        if (!loading)
          Wrap(spacing: 8, children: [
            TextButton.icon(
                onPressed: busy || phones.length >= 20
                    ? null
                    : () => setState(() => phones.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('إضافة رقم')),
            FilledButton(
                onPressed: busy ? null : save,
                child: Text(busy ? 'جارٍ الحفظ…' : 'حفظ أرقام التواصل'))
          ]),
        if (error != null)
          TextButton(
              onPressed: busy ? null : load,
              child: const Text('إعادة تحميل الأرقام')),
      ]));
}
