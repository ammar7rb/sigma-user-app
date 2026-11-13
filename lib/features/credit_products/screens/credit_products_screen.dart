import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

/// "اشتر الآن وادفع لاحقًا": admin-listed credit products, credit requests,
/// the customer's request history with admin replies, and the credit-limit check.
class CreditProductsScreen extends StatefulWidget {
  const CreditProductsScreen({super.key});

  @override
  State<CreditProductsScreen> createState() => _CreditProductsScreenState();
}

class _CreditProductsScreenState extends State<CreditProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  bool _failed = false;
  bool _sendingLimit = false;

  bool get _loggedIn =>
      Provider.of<AuthController>(context, listen: false).isLoggedIn();

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<Map<String, dynamic>> _asList(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final dio = di.sl<DioClient>();
      final products = await dio.get('/api/v1/credit-products');
      List<Map<String, dynamic>> requests = [];
      if (_loggedIn) {
        try {
          final mine = await dio.get('/api/v1/credit-products/my-requests');
          requests = _asList(mine.data['requests']);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _products = _asList(products.data['data']);
        _requests = requests;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _error(Object e) {
    try {
      final dynamic data = (e as dynamic).response?.data;
      if (data is Map && data['message'] != null) return '${data['message']}';
    } catch (_) {}
    return 'تعذر إرسال الطلب. حاول مرة أخرى.';
  }

  Future<void> _checkLimit() async {
    if (!_loggedIn) {
      _toast('سجّل الدخول أولًا لإرسال طلبك.');
      return;
    }
    setState(() => _sendingLimit = true);
    try {
      final response = await di.sl<DioClient>().post('/api/v1/credit-limit-request');
      _toast('${response.data['message'] ?? 'سيتم مراجعة الحد الائتماني والتواصل معكم قريبًا.'}');
    } catch (e) {
      _toast(_error(e));
    } finally {
      if (mounted) setState(() => _sendingLimit = false);
    }
  }

  Future<void> _requestCredit(Map<String, dynamic> product) async {
    if (!_loggedIn) {
      _toast('سجّل الدخول أولًا لإرسال طلب الائتمان.');
      return;
    }
    final controller = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('طلب ائتمان: ${product['name'] ?? ''}'),
          content: TextField(
            controller: controller,
            maxLength: 189,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'رسالة للإدارة (اختياري)'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('إرسال الطلب')),
          ],
        ),
      ),
    );
    final message = controller.text.trim();
    controller.dispose();
    if (send != true) return;
    try {
      final response = await di.sl<DioClient>().post(
          '/api/v1/credit-products/${product['id']}/request',
          data: {if (message.isNotEmpty) 'message': message});
      _toast('${response.data['message'] ?? 'تم إرسال طلب الائتمان.'}');
      await _load();
    } catch (e) {
      _toast(_error(e));
    }
  }

  String? _image(dynamic value) {
    if (value is Map && value['path'] != null) return '${value['path']}';
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  Widget _thumb(String? url) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: url == null
            ? Container(
                width: 72,
                height: 72,
                color: Colors.black12,
                child: const Icon(Icons.inventory_2_outlined))
            : Image.network(url,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image_outlined))),
      );

  Widget _productCard(Map<String, dynamic> p) {
    final price = double.tryParse('${p['unit_price']}') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _thumb(_image(p['thumbnail_full_url'])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p['name'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if ('${p['public_code'] ?? ''}'.isNotEmpty)
                Text('كود: ${p['public_code']}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text('${price.toStringAsFixed(2)} ج.م'),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton(
                    onPressed: () => _requestCredit(p),
                    child: const Text('طلب ائتمان')),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  String _statusLabel(String? s) =>
      s == 'responded' ? 'تم الرد' : 'قيد المراجعة';

  Widget _requestCard(Map<String, dynamic> r) {
    final responded = r['status'] == 'responded';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _thumb(_image(r['product_thumbnail'])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${r['product_name'] ?? 'منتج'}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('رقم الطلب: ${r['reference'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Chip(
                  label: Text(_statusLabel('${r['status']}')),
                  backgroundColor:
                      responded ? const Color(0xFFDFF5E8) : const Color(0xFFFFF3D9)),
              if (responded && '${r['admin_response'] ?? ''}'.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.05),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('رد الإدارة: ${r['admin_response']}'),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('اشتر الآن وادفع لاحقًا'),
            bottom: const TabBar(tabs: [Tab(text: 'المنتجات'), Tab(text: 'طلباتي')]),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _failed
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('تعذر تحميل الصفحة.'),
                      TextButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                    ]))
                  : TabBarView(children: [
                      RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(children: [
                          Card(
                            margin: const EdgeInsets.all(12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'اطلب التقسيط المباشر أو اشتر الآن وادفع لاحقًا',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    const Text(
                                        'أرسل طلبك وتراجع الإدارة الحد الائتماني وتتواصل معك. إرسال الطلب لا يعني الموافقة على التمويل.',
                                        style: TextStyle(fontSize: 12.5)),
                                    const SizedBox(height: 10),
                                    FilledButton(
                                        onPressed: _sendingLimit ? null : _checkLimit,
                                        child: Text(_sendingLimit
                                            ? 'جارٍ إرسال طلبك…'
                                            : 'تحقق من الحد الائتماني الآن')),
                                  ]),
                            ),
                          ),
                          if (_products.isEmpty)
                            const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(child: Text('لا توجد منتجات متاحة حاليًا.')))
                          else
                            ..._products.map(_productCard),
                        ]),
                      ),
                      RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(children: [
                          if (!_loggedIn)
                            const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(child: Text('سجّل الدخول لمتابعة طلباتك.')))
                          else if (_requests.isEmpty)
                            const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(child: Text('لا توجد طلبات ائتمان بعد.')))
                          else
                            ..._requests.map(_requestCard),
                        ]),
                      ),
                    ]),
        ),
      ),
    );
  }
}
