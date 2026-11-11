/// Customer-facing order progress from the Sigma customer spec:
/// three stages, with cancellation beside the bar while the website still
/// accepts a cancellation request.
class CustomerOrderProgress {
  static const labels = ['جاري التجهيز', 'جاري الشحن', 'تم التسليم'];

  static const cancellable = {
    'pending',
    'confirmed',
    'processing',
    'out_for_delivery',
  };

  /// 1-based stage. Zero means the bar is hidden (cancelled, failed, unknown).
  static int stage(String? status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
      case 'processing':
        return 1;
      case 'out_for_delivery':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  static bool canCancel(String? status) => cancellable.contains(status);
}
