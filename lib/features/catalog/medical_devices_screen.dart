import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_contract.dart';

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

  List<Map<String, dynamic>> get devices {
    final data = result?.data;
    if (data is! Map || data['devices'] is! List) return const [];
    return (data['devices'] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأجهزة الطبية')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
                'المنتجات هنا من الإدارة. طلب التقرير الفني يُدفع من المحفظة، وطلب الشراء يظهر بعد سداد التقرير فقط.'),
            const SizedBox(height: 12),
            if (busy) const LinearProgressIndicator(),
            if (result != null && !result!.ok)
              _Notice(result!.message),
            if (result != null && result!.ok && devices.isEmpty)
              const _Notice('لا توجد أجهزة منشورة.'),
            for (final device in devices)
              Card(
                child: ListTile(
                  title: Text('${device['name'] ?? 'جهاز'}'),
                  subtitle: Text(
                      '${device['device_condition'] == 'used' ? 'مستعمل' : 'جديد'}'
                      '${device['origin_country'] == null ? '' : ' · ${device['origin_country']}'}'
                      '\nسعر الجهاز: ${device['price'] ?? '—'} · التقرير: ${device['report_price'] ?? '—'}'),
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
    if (data is Map && data['id'] != null) return Map<String, dynamic>.from(data);
    return null;
  }

  bool get unlocked => device?['purchase_unlocked'] == true;

  Future<void> load() async {
    setState(() => busy = true);
    final response = await client.getList(CatalogContract.medicalDevice(widget.id));
    if (mounted) {
      setState(() {
        result = response;
        busy = false;
      });
    }
  }

  Future<void> payReport() async {
    setState(() => busy = true);
    final response = await client.post(
      CatalogContract.medicalReportPayment(widget.id),
      {'request_key': CatalogClient.requestKey()},
    );
    if (!mounted) return;
    setState(() {
      busy = false;
      notice = response.message;
    });
    if (response.ok) await load();
  }

  Future<void> requestPurchase() async {
    setState(() => busy = true);
    final response = await client.post(
        CatalogContract.medicalPurchaseRequest(widget.id), {});
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
            if (!unlocked)
              FilledButton(
                  onPressed: busy ? null : payReport,
                  child: const Text('طلب تقرير فني')),
            if (unlocked)
              FilledButton(
                  onPressed: busy ? null : requestPurchase,
                  child: const Text('طلب شراء')),
            const SizedBox(height: 8),
            const Text(
                'ثمن التقرير لا يُسترد. بعد طلب الشراء يكون الرد: تم استلام طلبكم وسيتم التواصل معكم في أقرب وقت.'),
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
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(text,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer))),
      );
}
