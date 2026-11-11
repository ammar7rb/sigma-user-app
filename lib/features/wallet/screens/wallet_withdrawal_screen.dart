import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';

class WalletWithdrawalScreen extends StatefulWidget {
  const WalletWithdrawalScreen({super.key});
  @override
  State<WalletWithdrawalScreen> createState() => _WalletWithdrawalScreenState();
}

class _WalletWithdrawalScreenState extends State<WalletWithdrawalScreen> {
  final amount = TextEditingController();
  Map? data;
  String? error;
  bool busy = false;
  bool accepted = false;
  Map<String, dynamic>? pending;

  String requestKey() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20)
    ].join('-');
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final response =
          await di.sl<DioClient>().get('/api/v1/customer/wallet/withdrawals');
      if (mounted) {
        setState(() {
          data = response.data as Map;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر تحميل طلبات السحب.');
    }
  }

  Future<void> submit() async {
    if (busy || data == null || (!accepted && pending == null)) return;
    final value = double.tryParse(amount.text);
    if (pending == null && (value == null || value <= 0 || !value.isFinite)) {
      setState(() => error = 'أدخل مبلغًا صحيحًا.');
      return;
    }
    pending ??= {
      'amount': amount.text,
      'expected_fee_percent': data!['feePercent'],
      'request_key': requestKey(),
      'currency_code':
          context.read<SplashController>().myCurrency?.code ?? 'EGP',
      'acknowledge': true,
    };
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await di
          .sl<DioClient>()
          .post('/api/v1/customer/wallet/withdrawals', data: pending);
      pending = null;
      if (!mounted) return;
      amount.clear();
      setState(() => accepted = false);
      await load();
    } catch (exception) {
      if (!mounted) return;
      final response = exception is DioException ? exception.response : null;
      final status = response?.statusCode;
      if (status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        pending = null;
        await load();
      }
      if (mounted) {
        setState(
            () => error = 'تعذر تأكيد طلب السحب. راجع البيانات وأعد المحاولة.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = double.tryParse(data?['feePercent'].toString() ?? '') ?? 0;
    final value = double.tryParse(amount.text) ?? 0;
    final currency =
        context.watch<SplashController>().myCurrency?.code ?? 'EGP';
    return Scaffold(
      appBar: AppBar(title: const Text('سحب رصيد المحفظة')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(padding: const EdgeInsets.all(24), children: [
          if (error != null)
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (data == null)
            const LinearProgressIndicator()
          else ...[
            Text('رسوم الإدارة والتشغيل $fee%. تبدأ المهلة من اعتماد الإدارة.'),
            TextField(
              controller: amount,
              enabled: !busy && pending == null,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'مبلغ السحب ($currency)'),
              onChanged: (_) => setState(() {}),
            ),
            Text('الرسوم ${(value * fee / 100).toStringAsFixed(2)} $currency'),
            Text(
                'الصافي ${(value * (1 - fee / 100)).toStringAsFixed(2)} $currency'),
            CheckboxListTile(
              value: accepted,
              onChanged: busy || pending != null
                  ? null
                  : (value) => setState(() => accepted = value == true),
              title: const Text('أوافق على حجز المبلغ وخصم الرسوم عند الصرف'),
            ),
            FilledButton(
              onPressed: busy || (!accepted && pending == null) ? null : submit,
              child:
                  Text(pending == null ? 'طلب السحب' : 'إعادة إرسال نفس الطلب'),
            ),
            const SizedBox(height: 24),
            for (final row
                in (data!['withdrawals'] as Map?)?['data'] as List? ?? [])
              ListTile(
                title: Text('طلب #${row['id']} · ${row['status']}'),
                subtitle: Text(
                    'الصافي ${row['net_amount']} بعملة المحفظة الأساسية\nموعد الصرف ${row['due_at'] ?? 'بعد الاعتماد'}'),
              ),
          ],
        ]),
      ),
    );
  }
}
