import 'package:flutter/material.dart';
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
          Text(getTranslated('your_account_number_is', context) ?? '',
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          SelectableText(accountNumber,
              textDirection: TextDirection.ltr,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      );
}
