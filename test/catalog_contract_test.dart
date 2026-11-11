import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_contract.dart';

void main() {
  test('unreleased catalog calls use the documented customer API paths', () {
    expect(CatalogContract.medicalDevices, '/api/v1/medical-devices');
    expect(CatalogContract.medicalReportPayment(4),
        '/api/v1/medical-devices/4/report-payment');
    expect(CatalogContract.medicalPurchaseRequest(4),
        '/api/v1/medical-devices/4/purchase-request');
    expect(CatalogContract.creditRequest(9), '/api/v1/credit-products/9/request');
  });
}
