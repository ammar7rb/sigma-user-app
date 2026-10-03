import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/contact_us/screens/contact_us_screen.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => const ContactUsScreen(isPasswordReset: true);
}
