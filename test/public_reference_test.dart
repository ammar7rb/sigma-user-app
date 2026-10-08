import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/public_reference_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/domain/models/customer_order_insurance_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';

void main() {
  test('invoice reference is not derived from the order reference', () {
    final invoice = CustomerOrderInsuranceEnvelope.fromJson({
      'invoice_number': 'IV7',
      'claim': {'order_reference': '#100010'},
    });
    expect(invoice.invoiceNumber, 'IV7');
    expect(invoice.claim.orderReference, '#100010');
    expect(CustomerOrderInsuranceEnvelope.fromJson({}).invoiceNumber, isNull);
  });
  test('product keeps its numeric ID for requests', () {
    final product = ProductDetailsModel(id: 9);
    expect(product.productNumber, 'P9');
    expect(product.id, 9);
    expect(ProductDetailsModel().productNumber, isNull);
  });
  for (final reference in ['ADC17', 'AIC18', 'CIP19']) {
    testWidgets('$reference remains readable in Arabic layout', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: PublicReferenceWidget(reference: reference)),
      )));
      final text = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(text.data, reference);
      expect(text.textDirection, TextDirection.ltr);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('missing reference does not manufacture a transaction',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: PublicReferenceWidget(reference: null)));
    expect(find.byType(SelectableText), findsNothing);
  });
}
