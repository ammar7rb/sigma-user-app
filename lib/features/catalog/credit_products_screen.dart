import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_contract.dart';

class CreditProductsScreen extends StatefulWidget {
  const CreditProductsScreen({super.key});
  @override
  State<CreditProductsScreen> createState() => _CreditProductsScreenState();
}

class _CreditProductsScreenState extends State<CreditProductsScreen> {
  final client = CatalogClient();
  CatalogCall? result;
  bool busy = false;
  String? notice;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => busy = true);
    final response = await client.getList(CatalogContract.creditProducts);
    if (mounted) {
      setState(() {
        result = response;
        busy = false;
      });
    }
  }

  List<Map<String, dynamic>> get products {
    final data = result?.data;
    final rows = data is Map ? data['products'] : null;
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<void> requestCredit(int id) async {
    setState(() => busy = true);
    final response = await client.post(CatalogContract.creditRequest(id), {});
    if (mounted) {
      setState(() {
        busy = false;
        notice = response.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اشترِ الآن وادفع لاحقًا')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
                'إعلانات الإدارة فقط. الزر هنا طلب ائتمان، وليس إضافة إلى السلة.'),
            const SizedBox(height: 12),
            if (busy) const LinearProgressIndicator(),
            if (notice != null) _Banner(notice!),
            if (result != null && !result!.ok) _Banner(result!.message),
            if (result != null && result!.ok && products.isEmpty)
              const _Banner('لا توجد منتجات ائتمان منشورة.'),
            for (final product in products)
              Card(
                child: ListTile(
                  title: Text('${product['name'] ?? 'منتج'}'),
                  subtitle: Text('${product['price'] ?? product['unit_price'] ?? '—'}'),
                  trailing: FilledButton(
                    onPressed: busy
                        ? null
                        : () {
                            final id = int.tryParse('${product['id']}');
                            if (id != null) requestCredit(id);
                          },
                    child: const Text('طلب ائتمان'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  const _Banner(this.text);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(color: Theme.of(context).colorScheme.error)));
}
