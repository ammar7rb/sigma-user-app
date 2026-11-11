import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_contract.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

class MedicalDevicesScreen extends StatefulWidget {
  const MedicalDevicesScreen({super.key});
  @override
  State<MedicalDevicesScreen> createState() => _MedicalDevicesScreenState();
}

class _MedicalDevicesScreenState extends State<MedicalDevicesScreen> {
  final client = CatalogClient();
  CatalogCall? result;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => busy = true);
    final response = await client.getList(CatalogContract.medicalDevices);
    if (mounted) {
      setState(() {
        result = response;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices =
        result == null ? const <Map<String, dynamic>>[] : CatalogClient.pageItems(result!.data);
    return Scaffold(
      appBar: AppBar(title: const Text('الأجهزة الطبية')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
                'منتجات الإدارة. سداد التقرير من المحفظة، وطلب الشراء يظهر بعد إرسال التقرير.'),
            const SizedBox(height: 12),
            if (busy) const LinearProgressIndicator(),
            if (result != null && !result!.ok) _Notice(result!.message),
            if (result != null && result!.ok && devices.isEmpty)
              const _Notice('لا توجد أجهزة منشورة.'),
            for (final device in devices)
              Card(
                child: ListTile(
                  title: Text('${device['name'] ?? 'جهاز'}'),
                  subtitle: Text(
                      '${device['device_condition'] == 'used' ? 'مستعمل' : 'جديد'}'
                      '${device['origin_country'] == null ? '' : ' · ${device['origin_country']}'}'
                      '\nالسعر: ${device['price'] ?? '—'} · التقرير: ${device['report_price'] ?? '—'}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {
                    final id = int.tryParse('${device['id']}');
                    if (id == null) return;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MedicalDeviceDetailScreen(id: id)));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MedicalDeviceDetailScreen extends StatefulWidget {
  final int id;
  const MedicalDeviceDetailScreen({super.key, required this.id});
  @override
  State<MedicalDeviceDetailScreen> createState() =>
      _MedicalDeviceDetailScreenState();
}

class _MedicalDeviceDetailScreenState extends State<MedicalDeviceDetailScreen> {
  final client = CatalogClient();
  CatalogCall? result;
  bool busy = false;
  String? notice;

  @override
  void initState() {
    super.initState();
    load();
  }

  Map<String, dynamic>? get device {
    final data = result?.data;
    if (data is Map && data['device'] is Map) {
      return Map<String, dynamic>.from(data['device'] as Map);
    }
    return null;
  }

  bool get canPurchase => result?.data is Map &&
      (result!.data as Map)['can_request_purchase'] == true;

  bool get reportPaid =>
      result?.data is Map && (result!.data as Map)['report_purchase'] != null;

  Future<void> load() async {
    setState(() => busy = true);
    final response =
        await client.getList(CatalogContract.medicalDevice(widget.id));
    if (mounted) {
      setState(() {
        result = response;
        busy = false;
      });
    }
  }

  bool _signedIn() {
    final signedIn = context.read<AuthController>().isLoggedIn();
    if (!signedIn) {
      RouterHelper.getLoginRoute(action: RouteAction.push);
    }
    return signedIn;
  }

  Future<void> payReport() async {
    if (!_signedIn()) return;
    final price = num.tryParse('${device?['report_price']}');
    if (price == null || price <= 0) {
      setState(() => notice = 'سعر التقرير غير متاح حاليًا.');
      return;
    }
    setState(() => busy = true);
    final response = await client.post(
      CatalogContract.medicalReportPayment(widget.id),
      {'report_price': price},
    );
    if (!mounted) return;
    setState(() {
      busy = false;
      notice = response.ok ? 'تم سداد ثمن التقرير الفني.' : response.message;
    });
    if (response.ok) await load();
  }

  Future<void> requestPurchase() async {
    if (!_signedIn()) return;
    setState(() => busy = true);
    final response = await client
        .post(CatalogContract.medicalPurchaseRequest(widget.id), {});
    if (mounted) {
      setState(() {
        busy = false;
        notice = response.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = device;
    return Scaffold(
      appBar: AppBar(title: Text(item?['name']?.toString() ?? 'الجهاز')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (busy) const LinearProgressIndicator(),
          if (result != null && !result!.ok) _Notice(result!.message),
          if (notice != null) _Notice(notice!),
          if (item != null) ...[
            Text('${item['name']}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(item['device_condition'] == 'used' ? 'مستعمل' : 'جديد'),
            if (item['origin_country'] != null)
              Text('بلد المنشأ: ${item['origin_country']}'),
            Text('السعر: ${item['price'] ?? '—'}'),
            Text('ثمن التقرير الفني: ${item['report_price'] ?? '—'}'),
            const SizedBox(height: 8),
            Text('${item['description'] ?? ''}'),
            const SizedBox(height: 16),
            if (!reportPaid)
              FilledButton(
                  onPressed: busy ? null : payReport,
                  child: const Text('طلب تقرير فني')),
            if (reportPaid && !canPurchase)
              const Text(
                  'سيظهر طلب الشراء بعد تأكيد الدفع وإرسال التقرير الفني.'),
            if (canPurchase)
              FilledButton(
                  onPressed: busy ? null : requestPurchase,
                  child: const Text('طلب شراء')),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(padding: const EdgeInsets.all(12), child: Text(text)),
      );
}
