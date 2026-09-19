import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/screens/pending_post_purchase_invoices_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
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
  Widget build(BuildContext context) {
    final insurance = map(data?['insurance']);
    return Scaffold(
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
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                            value: 'purchase',
                            label: Text(tr('purchase_wallet')),
                            icon: const Icon(Icons.shopping_bag_outlined)),
                        ButtonSegment(
                            value: 'insurance',
                            label: Text(tr('insurance_wallet')),
                            icon: const Icon(Icons.shield_outlined)),
                      ],
                      selected: {selectedWallet},
                      onSelectionChanged: (value) =>
                          setState(() => selectedWallet = value.first),
                    ),
                    const SizedBox(height: 14),
                    if (selectedWallet == 'purchase')
                      balance('purchase_wallet', data!['purchase_balance'],
                          Icons.shopping_bag_outlined, 'purchase')
                    else
                      balance(
                          'insurance_wallet',
                          insurance['available_balance'],
                          Icons.shield_outlined,
                          'insurance'),
                    if ((int.tryParse(
                                '${data!['pending_invoices_count'] ?? 0}') ??
                            0) >
                        0)
                      card(ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.pending_actions_rounded,
                            color: Colors.orange),
                        title: Text(tr('pending_completion_orders')),
                        subtitle: Text(
                            '${tr('pending_orders_count')}: ${data!['pending_invoices_count']}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PendingPostPurchaseInvoicesScreen(),
                          ),
                        ),
                      )),
                    if (selectedWallet == 'insurance')
                      card(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${tr('insurance_held_balance')}: ${money(insurance['held_balance'])}'),
                            if (insurance['next_maturity_at'] != null)
                              Text(
                                  '${tr('next_insurance_maturity')}: ${insurance['next_maturity_at']}'),
                            const SizedBox(height: 8),
                            Text(tr('wallet_reuse_notice')),
                          ])),
                    Text(tr('wallet_deposit_history'),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final item in pagedItems('deposits'))
                      if (item['wallet_type'] == selectedWallet)
                        card(ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(item['wallet_type'] == 'insurance'
                                ? Icons.shield_outlined
                                : Icons.shopping_bag_outlined),
                            title: Text(item['status'] == 'approved'
                                ? tr('wallet_deposit_success')
                                : '${money(item['amount'])} · ${tr('wallet_status_${item['status']}')}'),
                            subtitle: Text(
                                '${item['created_at']}${item['status'] == 'approved' || item['review_note'] == null ? '' : '\n${item['review_note']}'}'))),
                    if (pagedItems('deposits').isEmpty)
                      Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(tr('wallet_no_records'))),
                    if (selectedWallet == 'insurance')
                      Text(tr('wallet_order_history'),
                          style: Theme.of(context).textTheme.titleLarge),
                    if (selectedWallet == 'insurance')
                      const SizedBox(height: 12),
                    for (final item in pagedItems('orders'))
                      if (selectedWallet == 'insurance')
                        card(ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.receipt_long_outlined),
                            title: Text(
                                '#${item['id']} · ${money(item['amount'])}'),
                            subtitle: Text(
                                '${tr('insurance_wallet')}: ${money(item['insurance']?['amount'])}\n${tr('next_insurance_maturity')}: ${item['insurance']?['matures_at'] ?? tr('wallet_not_scheduled')}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                RouterHelper.getOrderDetailsScreenRoute(
                                    orderId: item['id'],
                                    action: RouteAction.push,
                                    isNotification: true))),
                    if (selectedWallet == 'purchase')
                      Text(tr('wallet_history'),
                          style: Theme.of(context).textTheme.titleLarge),
                    for (final item in pagedItems('purchase_entries'))
                      if (selectedWallet == 'purchase')
                        card(ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${tr('wallet_credit')}: ${money(item['credit'])} · ${tr('wallet_debit')}: ${money(item['debit'])}'),
                            subtitle: Text(
                                '${tr('purchase_wallet')}: ${money(item['balance'])} · ${item['created_at']}'))),
                    if (selectedWallet == 'insurance')
                      Text(tr('wallet_insurance_history'),
                          style: Theme.of(context).textTheme.titleLarge),
                    for (final item in list(data!['insurance_entries']))
                      if (selectedWallet == 'insurance')
                        card(ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${tr('wallet_credit')}: ${money(item['credit'])} · ${tr('wallet_debit')}: ${money(item['debit'])}'),
                            subtitle: Text(
                                '${item['order_id'] == null ? '' : '#${item['order_id']} · '}${item['created_at']}'))),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: page > 1
                                  ? () {
                                      setState(() {
                                        page--;
                                      });
                                      load();
                                    }
                                  : null,
                              child: Text(tr('wallet_previous'))),
                          Text('$page'),
                          TextButton(
                              onPressed: (map(data!['orders'])[
                                              'next_page_url'] !=
                                          null ||
                                      map(data!['deposits'])['next_page_url'] !=
                                          null ||
                                      map(data!['purchase_entries'])[
                                              'next_page_url'] !=
                                          null)
                                  ? () {
                                      setState(() {
                                        page++;
                                      });
                                      load();
                                    }
                                  : null,
                              child: Text(tr('wallet_next'))),
                        ]),
                  ])));
  }
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

  Map? get transferMethod {
    final methods = (widget.config['offline_methods'] as List? ?? const [])
        .whereType<Map>()
        .toList();
    if (channel == null || methods.isEmpty) return null;
    final explicit = methods.where((item) =>
        item['payment_channel']?.toString().trim().toLowerCase() == channel);
    if (explicit.isNotEmpty) return explicit.first;

    // Keep deposits working with payment methods created before
    // `payment_channel` was introduced in the administration panel.
    final inferred = methods.where((item) {
      final searchable = [
        item['method_name'],
        item['method_fields'],
        item['method_informations'],
      ].join(' ').toLowerCase();
      if (channel == 'instapay') {
        return searchable.contains('instapay') ||
            searchable.contains('insta pay') ||
            searchable.contains('انستا') ||
            searchable.contains('إنستا');
      }
      return searchable.contains('wallet') ||
          searchable.contains('محفظ') ||
          searchable.contains('vodafone') ||
          searchable.contains('orange cash') ||
          searchable.contains('etisalat cash') ||
          searchable.contains('we pay');
    });
    if (inferred.isNotEmpty) return inferred.first;

    // Legacy installations commonly stored one combined wallet/InstaPay
    // method. It remains usable for either choice until the administrator
    // separates the two methods.
    if (methods.length == 1 &&
        (methods.first['payment_channel'] == null ||
            methods.first['payment_channel'].toString().trim().isEmpty)) {
      return methods.first;
    }
    return null;
  }

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
              'payment_reference': requestKey,
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
            Row(children: [
              Expanded(
                  child: _CustomerTransferChoice(
                icon: Icons.account_balance_wallet_outlined,
                title: tr('electronic_wallet_payment'),
                selected: channel == 'wallet',
                onTap: busy ? null : () => setState(() => channel = 'wallet'),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _CustomerTransferChoice(
                icon: Icons.account_balance_rounded,
                title: tr('instapay_payment'),
                selected: channel == 'instapay',
                onTap: busy ? null : () => setState(() => channel = 'instapay'),
              )),
            ]),
            if (transferMethod != null) ...[
              const SizedBox(height: 16),
              Text(tr('transfer_using_admin_details'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final field
                  in transferMethod!['method_fields'] as List? ?? [])
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SelectableText(
                        '${field['input_name'] ?? ''}: ${field['input_data'] ?? ''}')),
              TextFormField(
                  controller: senderName,
                  maxLength: 100,
                  decoration: InputDecoration(
                      counterText: '', labelText: tr('sender_name')),
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
                      labelText: tr('sender_phone_or_account')),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true) ? tr('required') : null),
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
