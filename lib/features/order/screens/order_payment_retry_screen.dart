import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';

class OrderPaymentRetryScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  const OrderPaymentRetryScreen(
      {super.key, required this.orderId, required this.amount});
  @override
  State<OrderPaymentRetryScreen> createState() =>
      _OrderPaymentRetryScreenState();
}

class _OrderPaymentRetryScreenState extends State<OrderPaymentRetryScreen> {
  final form = GlobalKey<FormState>();
  final senderPhone = TextEditingController();
  final senderName = TextEditingController();
  late final String requestKey;
  XFile? proof;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    requestKey =
        '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  @override
  void dispose() {
    senderPhone.dispose();
    senderName.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    if (proof == null) {
      setState(() => error = 'أضف صورة إثبات الدفع.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await di.sl<DioClient>().dio!.post(
          '/api/v1/customer/order/${widget.orderId}/payment-proof/retry',
          data: FormData.fromMap({
            'request_key': requestKey,
            'transfer_schema': 'sender_v2',
            'sender_phone': EgyptPhoneHelper.normalizeLocal(senderPhone.text),
            'sender_name': senderName.text.trim(),
            'payment_proof':
                await MultipartFile.fromFile(proof!.path, filename: proof!.name)
          }));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => error =
            'تعذر إرسال الإثبات. تحقق من البيانات والاتصال ثم حاول مرة أخرى.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(title: const Text('إعادة تقديم إثبات الدفع')),
          body: Form(
              key: form,
              child: ListView(padding: const EdgeInsets.all(20), children: [
                Text('طلب رقم ${widget.orderId}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const Text('أرسل الإثبات لنفس الطلب دون إنشاء طلب جديد.'),
                const SizedBox(height: 24),
                TextFormField(
                    initialValue:
                        PriceConverter.convertPrice(context, widget.amount),
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: 'مبلغ الطلب',
                        suffixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 16),
                TextFormField(
                    controller: senderPhone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                        labelText: 'الرقم الذي حولت منه',
                        border: OutlineInputBorder()),
                    validator: (value) =>
                        EgyptPhoneHelper.isValidLocal(value ?? '')
                            ? null
                            : 'أدخل رقم موبايل مصري صحيحًا.'),
                const SizedBox(height: 16),
                TextFormField(
                    controller: senderName,
                    maxLength: 150,
                    decoration: const InputDecoration(
                        labelText: 'اسم المحفظة أو الحساب الخاص بك',
                        border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'أضف اسم الحساب أو المحفظة.'
                        : null),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () async {
                            final selected = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (selected == null) return;
                            if (await selected.length() > 5 * 1024 * 1024) {
                              if (mounted) {
                                setState(() => error =
                                    'حجم الصورة يجب ألا يتجاوز 5 ميجابايت.');
                              }
                              return;
                            }
                            if (mounted) {
                              setState(() {
                                proof = selected;
                                error = null;
                              });
                            }
                          },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(proof?.name ?? 'إضافة صورة إثبات الدفع')),
                if (error != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: busy ? null : submit,
                    child: Text(busy ? 'جارٍ الإرسال…' : 'إرسال للمراجعة')),
              ]))));
}
