import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';
import 'dart:math';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/transfer_recipient_card.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

/// The same restricted balances and review queue used by the customer website.
class CustomerWalletScreen extends StatefulWidget {
  final String initialWallet;
  const CustomerWalletScreen({super.key, this.initialWallet = 'purchase'});
  @override
  State<CustomerWalletScreen> createState() => _CustomerWalletScreenState();
}

class _CustomerWalletScreenState extends State<CustomerWalletScreen> {
  final DioClient api = di.sl<DioClient>();
  Map<String, dynamic>? data;
  String? error;
  int page = 1;
  late String selectedWallet;
  String tr(String key) => getTranslated(key, context) ?? key;
  String money(dynamic value) =>
      PriceConverter.convertPrice(context, double.tryParse('$value') ?? 0);
  List<dynamic> list(dynamic value) => value is List ? value : const [];
  Map<String, dynamic> map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  List<dynamic> pagedItems(String key) => list(map(data?[key])['data']);

  @override
  void initState() {
    super.initState();
    selectedWallet = widget.initialWallet;
    load();
  }

  Future<void> load() async {
    if (mounted) setState(() => error = null);
    try {
      final response = await api.get('/api/v1/customer/wallet/overview',
          queryParameters: {'page': page});
      if (mounted) {
        setState(() {
          data = Map<String, dynamic>.from(response.data);
          error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = tr('wallet_load_failed'));
    }
  }

  Widget card(Widget child) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16), child: child));

  Future<void> deposit(String wallet) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CustomerDepositScreen(wallet: wallet, config: data!)));
    await load();
  }

  Widget balance(String key, dynamic amount, IconData icon, String wallet) =>
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(tr(key), style: Theme.of(context).textTheme.titleMedium))
        ]),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(money(amount),
                style: Theme.of(context).textTheme.headlineSmall)),
        Text(tr('${wallet}_wallet_only_notice')),
        if ((wallet != 'purchase' || data!['purchase_enabled'] == true) &&
            (list(data!['offline_methods']).isNotEmpty ||
                list(data!['digital_methods']).isNotEmpty))
          TextButton.icon(
              onPressed: () => deposit(wallet),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(tr('wallet_make_deposit'))),
      ]));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(tr('wallet_my_wallet'))),
      body: RefreshIndicator(
          onRefresh: load,
          child: data == null
              ? ListView(children: [
                  const SizedBox(height: 80),
                  Center(
                      child: error == null
                          ? const CircularProgressIndicator()
                          : TextButton(onPressed: load, child: Text(error!)))
                ])
              : ListView(padding: const EdgeInsets.all(16), children: [
                  if (error != null) Text(error!),
                  balance('purchase_wallet', data!['purchase_balance'],
                      Icons.shopping_bag_outlined, 'purchase'),
                  Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(Icons.calendar_month_outlined,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                          title: Text('الاشتراك الشهري',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              map(data!['subscription'])['active'] == true
                                  ? 'فعال · متبقي ${map(data!['subscription'])['remaining_days']} يومًا'
                                  : 'إدارة الاشتراك والدفع',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                          trailing: const Icon(Icons.chevron_left),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MonthlySubscriptionScreen()));
                            await load();
                          })),
                  const SizedBox(height: 20),
                  Text(tr('wallet_deposit_history'),
                      style: Theme.of(context).textTheme.titleLarge),
                  for (final item in pagedItems('deposits'))
                    card(ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            '${money(item['amount'])} · ${tr('wallet_status_${item['status']}')}'),
                        subtitle: Text(
                            '${item['created_at']}${item['review_note'] == null ? '' : '\n${item['review_note']}'}'))),
                  if (pagedItems('deposits').isEmpty)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(tr('wallet_no_records'))),
                  const SizedBox(height: 20),
                  Text(tr('wallet_history'),
                      style: Theme.of(context).textTheme.titleLarge),
                  for (final item in pagedItems('purchase_entries'))
                    card(ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            '${tr('wallet_credit')}: ${money(item['credit'])} · ${tr('wallet_debit')}: ${money(item['debit'])}'),
                        subtitle: Text(
                            '${tr('purchase_wallet')}: ${money(item['balance'])} · ${item['created_at']}'))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: page > 1
                                ? () {
                                    setState(() => page--);
                                    load();
                                  }
                                : null,
                            child: Text(tr('wallet_previous'))),
                        Text('$page'),
                        TextButton(
                            onPressed:
                                map(data!['deposits'])['next_page_url'] !=
                                            null ||
                                        map(data!['purchase_entries'])[
                                                'next_page_url'] !=
                                            null
                                    ? () {
                                        setState(() => page++);
                                        load();
                                      }
                                    : null,
                            child: Text(tr('wallet_next')))
                      ]),
                ])));
}

class CustomerDepositScreen extends StatefulWidget {
  final String wallet;
  final Map<String, dynamic> config;
  const CustomerDepositScreen(
      {super.key, required this.wallet, required this.config});
  @override
  State<CustomerDepositScreen> createState() => _CustomerDepositScreenState();
}

class _CustomerDepositScreenState extends State<CustomerDepositScreen> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  final senderName = TextEditingController();
  final senderPhone = TextEditingController();
  final note = TextEditingController();
  final String requestKey = _uuid();
  String? channel;
  XFile? proof;
  bool busy = false;
  String? error;
  String tr(String key) => getTranslated(key, context) ?? key;
  static String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Map? _methodFor(String selectedChannel) {
    final methods = (widget.config['offline_methods'] as List? ?? const [])
        .whereType<Map>()
        .toList();
    final explicit = methods.where((item) =>
        item['payment_channel']?.toString().trim().toLowerCase() ==
        selectedChannel);
    if (explicit.isNotEmpty) return explicit.first;
    return null;
  }

  Map? get transferMethod => channel == null ? null : _methodFor(channel!);

  @override
  void dispose() {
    amount.dispose();
    senderName.dispose();
    senderPhone.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    if (transferMethod != null && proof == null) {
      setState(() => error = tr('wallet_proof_required'));
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final api = di.sl<DioClient>();
      final currency = context.read<SplashController>().myCurrency!.code;
      if (transferMethod != null) {
        final bytes = await proof!.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) throw StateError('proof_size');
        await api.post('/api/v1/customer/wallet/deposits',
            data: FormData.fromMap({
              'wallet_type': widget.wallet,
              'amount': amount.text.trim(),
              'currency_code': currency,
              'method_id': transferMethod!['id'],
              'request_key': requestKey,
              'transfer_schema': 'sender_v2',
              'sender_phone': EgyptPhoneHelper.normalizeLocal(senderPhone.text),
              'sender_name': senderName.text.trim(),
              'method_information[sender_name]': senderName.text.trim(),
              'method_information[sender_wallet_or_phone]':
                  senderPhone.text.trim(),
              if (note.text.trim().isNotEmpty) 'payment_note': note.text.trim(),
              'payment_proof':
                  MultipartFile.fromBytes(bytes, filename: proof!.name),
            }));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('wallet_deposit_pending'))));
        Navigator.of(context).pop();
      }
    } catch (exception) {
      if (mounted) {
        setState(() {
          final response =
              exception is DioException ? exception.response?.data : null;
          error = response is Map && response['message'] is String
              ? response['message']
              : tr('wallet_deposit_failed');
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(tr('wallet_make_deposit'))),
      body: Form(
          key: form,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text(tr('${widget.wallet}_wallet'),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(tr('${widget.wallet}_wallet_only_notice')),
            const SizedBox(height: 20),
            TextFormField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    InputDecoration(labelText: tr('wallet_deposit_amount')),
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  return number != null && number.isFinite && number > 0
                      ? null
                      : tr('wallet_invalid_amount');
                }),
            const SizedBox(height: 20),
            if (_methodFor('wallet') != null || _methodFor('instapay') != null)
              Row(children: [
                if (_methodFor('wallet') != null)
                  Expanded(
                      child: _CustomerTransferChoice(
                    icon: Icons.account_balance_wallet_outlined,
                    title: tr('electronic_wallet_payment'),
                    selected: channel == 'wallet',
                    onTap: busy
                        ? null
                        : () => setState(() {
                              channel = 'wallet';
                              senderPhone.clear();
                              proof = null;
                            }),
                  )),
                if (_methodFor('wallet') != null &&
                    _methodFor('instapay') != null)
                  const SizedBox(width: 10),
                if (_methodFor('instapay') != null)
                  Expanded(
                      child: _CustomerTransferChoice(
                    icon: Icons.account_balance_rounded,
                    title: tr('instapay_payment'),
                    selected: channel == 'instapay',
                    onTap: busy
                        ? null
                        : () => setState(() {
                              channel = 'instapay';
                              senderPhone.clear();
                              proof = null;
                            }),
                  )),
              ]),
            if (_methodFor('wallet') == null && _methodFor('instapay') == null)
              Text(tr('wallet_payment_method_unavailable')),
            if (transferMethod != null) ...[
              const SizedBox(height: 16),
              TransferRecipientCard(
                channel: channel!,
                details: [
                  for (final field
                      in (transferMethod!['method_fields'] as List? ?? const [])
                          .whereType<Map>())
                    TransferRecipientDetail('${field['input_name'] ?? ''}',
                        '${field['input_data'] ?? ''}'),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: senderName,
                  maxLength: 100,
                  decoration: InputDecoration(
                      counterText: '',
                      labelText: channel == 'instapay'
                          ? 'اسم الحساب الخاص بك'
                          : 'اسم المحفظة الخاصة بك',
                      hintText: tr('transfer_sender_full_name_hint')),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? tr('required') : null),
              TextFormField(
                  controller: note,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: InputDecoration(
                      counterText: '', labelText: tr('wallet_deposit_note'))),
              TextFormField(
                  controller: senderPhone,
                  keyboardType: TextInputType.phone,
                  maxLength: 30,
                  decoration: InputDecoration(
                      counterText: '',
                      labelText: 'الرقم الذي حولت منه',
                      hintText: tr(channel == 'instapay'
                          ? 'transfer_sender_instapay_hint'
                          : 'transfer_sender_wallet_hint')),
                  validator: (value) =>
                      EgyptPhoneHelper.isValidLocal(value ?? '')
                          ? null
                          : 'أدخل رقم موبايل مصري صحيحًا من 11 رقمًا.'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          final selected = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (mounted && selected != null) {
                            final extension =
                                selected.name.split('.').last.toLowerCase();
                            if (!const ['jpg', 'jpeg', 'png', 'webp']
                                .contains(extension)) {
                              setState(() =>
                                  error = tr('wallet_proof_invalid_format'));
                              return;
                            }
                            final length = await selected.length();
                            if (!mounted) return;
                            if (length > 5 * 1024 * 1024) {
                              setState(
                                  () => error = tr('wallet_proof_too_large'));
                              return;
                            }
                            setState(() {
                              proof = selected;
                              error = null;
                            });
                          }
                        },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(proof?.name ?? tr('wallet_upload_proof'))),
              Text(tr('wallet_deposit_review_notice')),
            ],
            if (channel != null && transferMethod == null)
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(tr('wallet_payment_method_unavailable'),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
            if (error != null)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: busy
                    ? null
                    : () {
                        if (transferMethod == null) {
                          setState(() => error = channel == null
                              ? tr('wallet_select_payment_method')
                              : tr('wallet_payment_method_unavailable'));
                          return;
                        }
                        submit();
                      },
                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(tr('proceed'))),
          ])));
}

class _CustomerTransferChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  const _CustomerTransferChoice(
      {required this.icon,
      required this.title,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? Theme.of(context).primaryColor.withValues(alpha: .09)
            : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 154,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon,
                            size: 25, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: 8),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20),
                  ]),
            ),
          ),
        ),
      );
}
