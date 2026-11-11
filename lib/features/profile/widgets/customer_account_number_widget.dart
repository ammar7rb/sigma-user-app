import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

class CustomerAccountNumberWidget extends StatelessWidget {
  final String accountNumber;
  final Color? color;
  const CustomerAccountNumberWidget(
      {super.key, required this.accountNumber, this.color});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SelectableText(accountNumber,
              textDirection: TextDirection.ltr,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          IconButton(
              tooltip: getTranslated('copy', context) ?? 'نسخ رقم الحساب',
              icon: Icon(Icons.content_copy_rounded, color: color, size: 19),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: accountNumber));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ رقم الحساب')));
                }
              }),
        ],
      );
}
