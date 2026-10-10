import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/egypt_phone_helper.dart';

class CheckoutRegistrationForm extends StatefulWidget {
  final Future<void> Function(String name, String phone, String password) onSubmit;
  final VoidCallback onLogin;
  final String? error;
  final bool busy;
  const CheckoutRegistrationForm({super.key, required this.onSubmit, required this.onLogin, this.error, this.busy = false});

  @override
  State<CheckoutRegistrationForm> createState() => _CheckoutRegistrationFormState();
}

class _CheckoutRegistrationFormState extends State<CheckoutRegistrationForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _consent = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('خطوة واحدة لحفظ طلبك', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      const Text('أنشئ حسابك لإكمال الشراء. ستبقى المنتجات التي اخترتها في سلتك.'),
      const SizedBox(height: 24),
      if (widget.error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Semantics(liveRegion: true, child: Text(widget.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
      TextFormField(controller: _name, autofillHints: const [AutofillHints.name], textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()),
        validator: (value) => value == null || value.trim().isEmpty || value.length > 100 ? 'أدخل اسمك، بحد أقصى 100 حرف' : null),
      const SizedBox(height: 20),
      TextFormField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, autofillHints: const [AutofillHints.telephoneNumber], textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'رقم الموبايل', helperText: '11 رقمًا يبدأ بـ 010 أو 011 أو 012 أو 015', border: OutlineInputBorder()),
        validator: (value) => EgyptPhoneHelper.isValidLocal(value ?? '') ? null : 'أدخل رقم موبايل مصري صحيح من 11 رقمًا'),
      const SizedBox(height: 20),
      TextFormField(controller: _password, obscureText: _obscure, maxLength: 128, autofillHints: const [AutofillHints.newPassword],
        decoration: InputDecoration(labelText: 'كلمة المرور', helperText: '8 أحرف على الأقل', border: const OutlineInputBorder(), suffixIcon: IconButton(tooltip: _obscure ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور', onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
        validator: (value) => value == null || value.length < 8 ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل' : null),
      const SizedBox(height: 12),
      CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, value: _consent,
        title: const Text('أوافق على الشروط والأحكام وسياسة الخصوصية'),
        onChanged: widget.busy ? null : (value) => setState(() => _consent = value ?? false)),
      const SizedBox(height: 16),
      FilledButton(onPressed: widget.busy || !_consent ? null : () async {
        if (_form.currentState!.validate()) await widget.onSubmit(_name.text.trim(), EgyptPhoneHelper.normalizeLocal(_phone.text), _password.text);
      }, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)), child: Text(widget.busy ? 'جارٍ إنشاء الحساب…' : 'إنشاء الحساب والعودة إلى طلبك')),
      TextButton(onPressed: widget.busy ? null : widget.onLogin, child: const Text('لديك حساب؟ سجّل الدخول')),
    ]),
  );
}
