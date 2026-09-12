import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

class PendingPostPurchaseInvoicesScreen extends StatefulWidget {
  const PendingPostPurchaseInvoicesScreen({super.key});

  @override
  State<PendingPostPurchaseInvoicesScreen> createState() =>
      _PendingPostPurchaseInvoicesScreenState();
}

class _PendingPostPurchaseInvoicesScreenState
    extends State<PendingPostPurchaseInvoicesScreen> {
  final DioClient _api = di.sl<DioClient>();
  List<Map<String, dynamic>>? _invoices;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _tr(String key) => getTranslated(key, context) ?? key;

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final response = await _api.get(
        '/api/v1/customer/post-purchase-invoices',
        queryParameters: {'limit': 50},
      );
      final raw = response.data is Map ? response.data['invoices'] : null;
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .where((item) =>
                  item['status'] == 'pending' ||
                  item['status'] == 'awaiting_review')
              .toList()
          : <Map<String, dynamic>>[];
      if (mounted) setState(() => _invoices = items);
    } on DioException catch (exception) {
      if (mounted) {
        setState(() => _error = exception.response?.statusCode == 401
            ? _tr('sign_in')
            : _tr('pending_orders_load_failed'));
      }
    } catch (_) {
      if (mounted) setState(() => _error = _tr('pending_orders_load_failed'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(title: _tr('pending_completion_orders')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _invoices == null
              ? ListView(children: [
                  const SizedBox(height: 160),
                  Center(
                    child: _error == null
                        ? const CircularProgressIndicator()
                        : _ErrorState(message: _error!, onRetry: _load),
                  ),
                ])
              : _invoices!.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 140),
                      Icon(Icons.task_alt_rounded,
                          size: 64, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 14),
                      Center(child: Text(_tr('no_pending_completion_orders'))),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _invoices!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final invoice = _invoices![index];
                        final orderId = int.tryParse('${invoice['order_id']}');
                        final due = double.tryParse(
                                '${invoice['external_amount_due'] ?? invoice['amount_due'] ?? invoice['total_amount']}') ??
                            0;
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: orderId == null
                                ? null
                                : () => RouterHelper.getCustomerOrderInsuranceRoute(
                                      orderId: orderId,
                                      action: RouteAction.push,
                                    ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.pending_actions_rounded,
                                        color: Theme.of(context).colorScheme.tertiary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('#${orderId ?? '-'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w700)),
                                    ),
                                    _StatusChip(status: '${invoice['status']}'),
                                  ]),
                                  const SizedBox(height: 14),
                                  Text('${_tr('amount_due')}: ${PriceConverter.convertPrice(context, due)}'),
                                  if ((double.tryParse('${invoice['insurance_amount']}') ?? 0) > 0)
                                    Text('${_tr('insurance_wallet')}: ${PriceConverter.convertPrice(context, double.tryParse('${invoice['insurance_amount']}') ?? 0)}'),
                                  if ((double.tryParse('${invoice['tax_amount']}') ?? 0) > 0)
                                    Text('${_tr('tax')}: ${PriceConverter.convertPrice(context, double.tryParse('${invoice['tax_amount']}') ?? 0)}'),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(child: Text(_tr('complete_payment'),
                                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700))),
                                    Text(_tr('view_invoice'), style: TextStyle(color: Theme.of(context).primaryColor)),
                                    Icon(Icons.chevron_right_rounded, color: Theme.of(context).primaryColor),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: status == 'awaiting_review'
              ? Colors.blue.withValues(alpha: .1)
              : Colors.orange.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(getTranslated('invoice_status_$status', context) ?? status,
            style: TextStyle(
              fontSize: 11,
              color: status == 'awaiting_review' ? Colors.blue : Colors.orange.shade800,
              fontWeight: FontWeight.w700,
            )),
      );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(getTranslated('retry', context) ?? 'Retry')),
      ]);
}
