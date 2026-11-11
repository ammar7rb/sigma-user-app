import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/customer_order_progress.dart';

void main() {
  test('order progress is three stages and cancel sits on active orders', () {
    expect(CustomerOrderProgress.labels, [
      'جاري التجهيز',
      'جاري الشحن',
      'تم التسليم',
    ]);
    expect(CustomerOrderProgress.stage('pending'), 1);
    expect(CustomerOrderProgress.stage('confirmed'), 1);
    expect(CustomerOrderProgress.stage('processing'), 1);
    expect(CustomerOrderProgress.stage('out_for_delivery'), 2);
    expect(CustomerOrderProgress.stage('delivered'), 3);
    expect(CustomerOrderProgress.stage('canceled'), 0);
    expect(CustomerOrderProgress.canCancel('pending'), isTrue);
    expect(CustomerOrderProgress.canCancel('out_for_delivery'), isTrue);
    expect(CustomerOrderProgress.canCancel('delivered'), isFalse);
    expect(CustomerOrderProgress.canCancel('canceled'), isFalse);
  });
}
