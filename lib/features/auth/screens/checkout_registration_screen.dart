import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/checkout_registration_form.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/required_registration_policy_links.dart';

class CheckoutRegistrationScreen extends StatefulWidget {
  const CheckoutRegistrationScreen({super.key});
  @override
  State<CheckoutRegistrationScreen> createState() => _CheckoutRegistrationScreenState();
}

class _CheckoutRegistrationScreenState extends State<CheckoutRegistrationScreen> {
  bool _busy = false;
  String? _error;
  bool _policiesReady = false;
  bool _accountCreated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final response = await di.sl<DioClient>().get('/api/v1/auth/registration-policies');
        if (mounted) {
          setState(() {
            _policies = List<Map<String, dynamic>>.from(response.data['policies'] ?? []);
            _policiesReady = true;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _error = 'تعذر تحميل السياسات. أعد فتح الصفحة بعد التحقق من الاتصال.');
        }
      }
    });
  }
  List<Map<String, dynamic>> _policies = [];

  Future<void> _register(String name, String phone, String password) async {
    setState(() { _busy = true; _error = null; });
    try {
      final client = di.sl<DioClient>();
      final response = await client.post('/api/v1/auth/checkout-register', data: {
        'name': name, 'phone': phone, 'password': password, 'terms_accepted': true,
        'policy_version_ids': _policies.map((policy) => policy['id']).toList(),
        'guest_id': context.read<AuthController>().getGuestToken(),
      });
      if (!mounted) return;
      final auth = context.read<AuthController>();
      await auth.authServiceInterface.saveUserToken(response.data['token'] as String);
      _accountCreated = true;
      if (!mounted) return;
      final cart = context.read<CartController>();
      final merged = await cart.mergeGuestCart();
      if (!merged) {
        if (mounted) {
          setState(() => _error = 'تم إنشاء حسابك، لكن تعذر تحديث السلة. ارجع إلى السلة وأعد المحاولة؛ المنتجات محفوظة.');
        }
        return;
      }
      if (!mounted) return;
      await cart.getCartData(context);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = 'تعذر إنشاء الحساب. تحقق من البيانات والاتصال. إذا كان الرقم مسجلًا، سجّل الدخول.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إكمال الشراء')),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: AutofillGroup(child: Column(children: [
      CheckoutRegistrationForm(
        busy: _busy || !_policiesReady || _accountCreated, error: _error, onSubmit: _register,
        onLogin: () {
          final cart = context.read<CartController>();
          RouterHelper.getLoginRoute(action: RouteAction.push, fromPage: RouterHelper.cartScreen, onLoginSuccess: () async {
            await cart.mergeGuestCart();
          });
        },
      ),
      RequiredRegistrationPolicyLinks(policies: _policies),
    ])))),
  );
}
