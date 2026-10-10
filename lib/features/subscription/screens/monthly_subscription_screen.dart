import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/transfer_recipient_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/monthly_subscription_summary.dart';

class MonthlySubscriptionScreen extends StatefulWidget {
  const MonthlySubscriptionScreen({super.key});
  @override
  State<MonthlySubscriptionScreen> createState() =>
      _MonthlySubscriptionScreenState();
}

class _MonthlySubscriptionScreenState extends State<MonthlySubscriptionScreen>
    with WidgetsBindingObserver {
  final api = di.sl<DioClient>();
  Map<String, dynamic>? data;
  String? error;
  bool busy = false;
  late final String requestKey;
  Map<String, dynamic> get subscription =>
      Map<String, dynamic>.from(data?['subscription'] ?? {});
  Map<String, dynamic>? get open => subscription['open_payment'] is Map
      ? Map<String, dynamic>.from(subscription['open_payment'])
      : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    requestKey =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !busy) load();
  }

  String failure(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final errors = e.response!.data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
      }
      final message = e.response!.data['message'];
      if (message is String &&
          message.isNotEmpty &&
          e.response!.statusCode != 500) {
        return message;
      }
    }
    return 'تعذر إتمام العملية. تحقق من الاتصال وأعد المحاولة.';
  }

  Future<void> load() async {
    try {
      final response = await api.get('/api/v1/customer/subscription');
      if (mounted) {
        setState(() {
          data = Map<String, dynamic>.from(response.data);
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = failure(e));
    }
  }

  Future<void> act(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
      await load();
      if (mounted) {
        await Provider.of<ProfileController>(context, listen: false)
            .getUserInfo(context);
      }
    } catch (e) {
      if (mounted) setState(() => error = failure(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> checkout() => act(() async {
        await api.post('/api/v1/customer/subscription/checkout',
            data: {'request_key': requestKey});
      });

  Future<void> wallet() async {
    final payment = open;
    if (payment == null || busy) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('دفع الاشتراك'),
                content: Text(
                    'سيتم خصم ${payment['quoted_amount']} ${payment['currency_code']} من محفظة المشتريات. يبدأ الاشتراك 30 يومًا من الاعتماد، دون تمديد الصلاحية السابقة.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('تأكيد الدفع'))
                ]));
    if (confirmed == true && mounted) {
      await act(() async {
        await api.post('/api/v1/customer/subscription/${payment['id']}/wallet');
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('الاشتراك الشهري')),
      body: RefreshIndicator(
          onRefresh: load,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            if (error != null)
              Semantics(
                  liveRegion: true,
                  child: Column(children: [
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    TextButton(
                        onPressed: busy ? null : load,
                        child: const Text('إعادة المحاولة'))
                  ])),
            if (data == null && error == null)
              const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator())),
            if (data != null) ...[
              MonthlySubscriptionSummary(
                  subscription: subscription,
                  busy: busy,
                  onCheckout:
                      open == null && subscription['payment_available'] == true
                          ? checkout
                          : null),
              if (open?['status'] == 'draft') ...[
                const SizedBox(height: 28),
                Text('اختر طريقة الدفع',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                    'المبلغ المطلوب: ${open!['quoted_amount']} ${open!['currency_code']}'),
                if (data!['purchase_wallet_enabled'] == true)
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          const Icon(Icons.account_balance_wallet_outlined),
                      title: const Text('محفظة المشتريات'),
                      subtitle: const Text('خصم مؤكد من الرصيد المعتمد'),
                      onTap: busy ? null : wallet),
                for (final method in data!['offline_methods'] as List? ?? [])
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.swap_horiz_rounded),
                      title: Text('${method['method_name']}'),
                      subtitle: Text(method['payment_channel'] == 'instapay'
                          ? 'InstaPay · مراجعة الإدارة'
                          : 'محفظة إلكترونية · مراجعة الإدارة'),
                      onTap: busy
                          ? null
                          : () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          SubscriptionTransferScreen(
                                              payment: open!,
                                              method: Map<String, dynamic>.from(
                                                  method))));
                              await load();
                              if (context.mounted) {
                                await Provider.of<ProfileController>(context,
                                        listen: false)
                                    .getUserInfo(context);
                              }
                            }),
                if (data!['purchase_wallet_enabled'] != true &&
                    (data!['offline_methods'] as List? ?? []).isEmpty)
                  const Text(
                      'لا توجد وسيلة دفع متاحة حاليًا. تواصل مع الإدارة.'),
              ],
              const SizedBox(height: 32),
              Text('سجل دفعات الاشتراك',
                  style: Theme.of(context).textTheme.titleLarge),
              for (final payment
                  in (data!['payments'] as Map?)?['data'] as List? ?? [])
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                        '${payment['quoted_amount']} ${payment['currency_code']}'),
                    subtitle: Text('${{
                      'draft': 'لم يُرسل الدفع بعد',
                      'pending_review': 'الدفع قيد المراجعة',
                      'approved': 'تم اعتماد الدفع',
                      'rejected': 'رُفض الدفع'
                    }[payment['status']]}${payment['review_note'] == null ? '' : '\n${payment['review_note']}'}'),
                    trailing: Text('#${payment['id']}')),
            ],
          ])));
}

class SubscriptionTransferScreen extends StatefulWidget {
  final Map<String, dynamic> payment, method;
  const SubscriptionTransferScreen(
      {super.key, required this.payment, required this.method});
  @override
  State<SubscriptionTransferScreen> createState() =>
      SubscriptionTransferScreenState();
}

class SubscriptionTransferScreenState
    extends State<SubscriptionTransferScreen> {
  String get quotedAmount {
    final value = double.tryParse('${widget.payment['quoted_amount']}') ?? 0;
    final cents = (value * 100).round() / 100;
    return value.toStringAsFixed((value - cents).abs() > 0.00001 ? 3 : 2);
  }

  final form = GlobalKey<FormState>();
  final senderPhone = TextEditingController();
  final senderName = TextEditingController();
  final information = <String, TextEditingController>{};
  XFile? proof;
  String? error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    senderPhone.dispose();
    senderName.dispose();
    for (final c in information.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    if (proof == null) {
      setState(() => error = 'أضف صورة إثبات الدفع.');
      return;
    }
    if (await proof!.length() > 5 * 1024 * 1024) {
      if (mounted) {
        setState(() => error = 'حجم الصورة يجب ألا يتجاوز 5 ميجابايت.');
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final body = FormData.fromMap({
        'method_id': widget.method['id'],
        'transfer_schema': 'sender_v2',
        'sender_phone': EgyptPhoneHelper.normalizeLocal(senderPhone.text),
        'sender_name': senderName.text.trim(),
        'transferred_amount': widget.payment['quoted_amount'],
        'payment_proof':
            await MultipartFile.fromFile(proof!.path, filename: proof!.name)
      });
      await di.sl<DioClient>().post(
          '/api/v1/customer/subscription/${widget.payment['id']}/offline',
          data: body);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          final errors = e is DioException && e.response?.data is Map
              ? e.response!.data['errors']
              : null;
          error = errors is Map && errors.isNotEmpty
              ? '${(errors.values.first as List).first}'
              : 'تعذر إرسال الدفع. تحقق من البيانات وأعد المحاولة.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('تحويل ودفع الاشتراك')),
      body: Form(
          key: form,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text(
                '$quotedAmount ${widget.payment['currency_code'] == 'EGP' ? 'ج.م' : widget.payment['currency_code']}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text(
                'حوّل المبلغ للجهة الموضحة، ثم أرسل الإثبات لمراجعة الإدارة.'),
            const SizedBox(height: 20),
            TransferRecipientCard(
                channel: '${widget.method['payment_channel']}',
                details: [
                  for (final field
                      in widget.method['method_fields'] as List? ?? [])
                    TransferRecipientDetail(
                        '${field['input_name']}', '${field['input_data']}')
                ]),
            const SizedBox(height: 20),
            TextFormField(
                initialValue: quotedAmount,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'مبلغ التحويل',
                    suffixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 16),
            TextFormField(
                controller: senderPhone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                    labelText: 'الرقم الذي حولت منه',
                    prefixIcon: Icon(Icons.phone_outlined)),
                validator: (value) => EgyptPhoneHelper.isValidLocal(value ?? '')
                    ? null
                    : 'أدخل رقم موبايل مصري صحيحًا من 11 رقمًا.'),
            const SizedBox(height: 16),
            TextFormField(
                controller: senderName,
                maxLength: 150,
                decoration: InputDecoration(
                    labelText: widget.method['payment_channel'] == 'instapay'
                        ? 'اسم الحساب الخاص بك'
                        : 'اسم المحفظة الخاصة بك',
                    prefixIcon: const Icon(Icons.person_outline)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'أضف اسم الحساب أو المحفظة.'
                    : null),
            const SizedBox(height: 16),
            OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        try {
                          final selected = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (mounted && selected != null) {
                            setState(() => proof = selected);
                          }
                        } catch (_) {
                          if (mounted) {
                            setState(() => error =
                                'تعذر فتح الصور. تحقق من صلاحية الوصول.');
                          }
                        }
                      },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(proof?.name ?? 'إضافة إثبات الدفع')),
            const Text('JPG أو PNG أو WebP، حتى 5 ميجابايت.'),
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
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                        busy ? 'جارٍ إرسال الدفع…' : 'إرسال الدفع للمراجعة'))),
          ])));
}
