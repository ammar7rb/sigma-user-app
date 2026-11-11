import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_contract.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

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

  String _price(Map<String, dynamic> product) =>
      '${product['unit_price'] ?? product['price'] ?? '—'}';

  Future<void> requestCredit(Map<String, dynamic> product) async {
    if (!context.read<AuthController>().isLoggedIn()) {
      RouterHelper.getLoginRoute(action: RouteAction.push);
      return;
    }
    final id = int.tryParse('${product['id']}');
    if (id == null) return;
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final field = TextEditingController();
        return AlertDialog(
          title: const Text('طلب ائتمان'),
          content: TextField(
            controller: field,
            maxLength: 189,
            decoration: const InputDecoration(
                labelText: 'رسالة للإدارة', counterText: ''),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, field.text.trim()),
                child: const Text('إرسال')),
          ],
        );
      },
    );
    if (message == null || !mounted) return;
    setState(() => busy = true);
    final response = await client.post(CatalogContract.creditRequest(id), {
      if (message.isNotEmpty) 'message': message,
    });
    if (mounted) {
      setState(() {
        busy = false;
        notice = response.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = result == null
        ? const <Map<String, dynamic>>[]
        : CatalogClient.pageItems(result!.data);
    return Scaffold(
      appBar: AppBar(title: const Text('اشترِ الآن وادفع لاحقًا')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('إعلانات الإدارة. الزر طلب ائتمان، وليس إضافة إلى السلة.'),
            const SizedBox(height: 12),
            if (busy) const LinearProgressIndicator(),
            if (notice != null) Text(notice!),
            if (result != null && !result!.ok) Text(result!.message),
            if (result != null && result!.ok && products.isEmpty)
              const Text('لا توجد منتجات ائتمان منشورة.'),
            for (final product in products)
              Card(
                child: ListTile(
                  title: Text('${product['name'] ?? 'منتج'}'),
                  subtitle: Text(_price(product)),
                  trailing: FilledButton(
                    onPressed: busy ? null : () => requestCredit(product),
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
