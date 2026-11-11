/// Routes from bahaa draft PR #2 (`cursor/sigma-fixes-20261111-e21d`,
/// `f487078`). Not on GitHub `production` until that PR is merged.
class CatalogContract {
  static const medicalDevices = '/api/v1/medical-devices';
  static String medicalDevice(int id) => '/api/v1/medical-devices/$id';
  static String medicalReportPayment(int id) =>
      '/api/v1/medical-devices/$id/report-payment';
  static String medicalPurchaseRequest(int id) =>
      '/api/v1/medical-devices/$id/purchase-request';
  static const creditProducts = '/api/v1/credit-products';
  static String creditRequest(int productId) =>
      '/api/v1/credit-products/$productId/request';

  static const unavailable =
      'المسار غير منشور على الإنتاج بعد. التطبيق لا يسجل الطلب محليًا.';
}
