import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/transfer_recipient_card.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/controllers/order_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class OrderOfflinePaymentScreen extends StatefulWidget {
  final double payableAmount;
  final String orderId;
  final Function callback;
  const OrderOfflinePaymentScreen(
      {super.key,
      required this.payableAmount,
      required this.callback,
      required this.orderId});
  @override
  State<OrderOfflinePaymentScreen> createState() =>
      _OrderOfflinePaymentScreenState();
}

class _OrderOfflinePaymentScreenState extends State<OrderOfflinePaymentScreen> {
  final form = GlobalKey<FormState>();
  final phone = TextEditingController(), name = TextEditingController();
  XFile? proof;
  int? methodId;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    phone.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !(form.currentState?.validate() ?? false)) return;
    if (methodId == null || proof == null) {
      setState(() => error = 'اختر وسيلة الدفع وأرفق صورة الإيصال.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (await proof!.length() > 5 * 1024 * 1024) {
        throw StateError('proof_size');
      }
      await di.sl<DioClient>().post(AppConstants.duePaymentByOfflinePayment,
          data: FormData.fromMap({
            'order_id': widget.orderId,
            'payment_method': 'offline_payment',
            'method_id': methodId,
            'method_informations': base64Encode(utf8.encode(jsonEncode({
              'transfer_schema': 'sender_v2',
              'sender_phone': EgyptPhoneHelper.normalizeLocal(phone.text),
              'sender_name': name.text.trim()
            }))),
            'payment_proof': await MultipartFile.fromFile(proof!.path,
                filename: proof!.name),
          }));
      if (!mounted) return;
      await context
          .read<OrderDetailsController>()
          .getOrderFromOrderId(widget.orderId);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => error =
            'تعذر إرسال الإيصال. تحقق من الصورة والبيانات ثم حاول مرة أخرى.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final methods = context
            .watch<CheckoutController>()
            .offlinePaymentModel
            ?.offlineMethods
            ?.where((m) =>
                m.paymentChannel == 'wallet' || m.paymentChannel == 'instapay')
            .toList() ??
        [];
    final matches = methods.where((m) => m.id == methodId);
    final selected = matches.isEmpty ? null : matches.first;
    return Scaffold(
        appBar: AppBar(title: const Text('دفع المبلغ المستحق')),
        body: Form(
            key: form,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text(PriceConverter.convertPrice(context, widget.payableAmount),
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                  initialValue: methodId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'طريقة التحويل'),
                  items: [
                    for (final m in methods)
                      DropdownMenuItem(
                          value: m.id, child: Text(m.methodName ?? ''))
                  ],
                  onChanged:
                      busy ? null : (id) => setState(() => methodId = id),
                  validator: (id) => id == null ? 'اختر طريقة التحويل.' : null),
              if (selected != null) ...[
                const SizedBox(height: 20),
                TransferRecipientCard(
                    channel: selected.paymentChannel ?? '',
                    details: [
                      for (final f in selected.methodFields ?? [])
                        TransferRecipientDetail(
                            f.inputName ?? '', f.inputData ?? '')
                    ]),
              ],
              const SizedBox(height: 20),
              TextFormField(
                  initialValue: PriceConverter.convertPrice(
                      context, widget.payableAmount),
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'مبلغ التحويل',
                      suffixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 16),
              TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration:
                      const InputDecoration(labelText: 'الرقم الذي حولت منه'),
                  validator: (v) => EgyptPhoneHelper.isValidLocal(v ?? '')
                      ? null
                      : 'أدخل رقم موبايل مصري صحيحًا.'),
              const SizedBox(height: 16),
              TextFormField(
                  controller: name,
                  maxLength: 150,
                  decoration: InputDecoration(
                      labelText: selected?.paymentChannel == 'instapay'
                          ? 'اسم الحساب الخاص بك'
                          : 'اسم المحفظة الخاصة بك'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'أضف اسم الحساب أو المحفظة.'
                      : null),
              OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          final file = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (mounted && file != null) {
                            setState(() => proof = file);
                          }
                        },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(proof?.name ?? 'أرفق صورة إيصال التحويل')),
              const Text('JPG أو PNG أو WebP، حتى 5 ميجابايت.'),
              if (error != null)
                Text(error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: busy ? null : submit,
                  child: Text(
                      busy ? 'جارٍ الإرسال…' : 'إرسال إيصال التحويل للمراجعة')),
            ])));
  }
}
