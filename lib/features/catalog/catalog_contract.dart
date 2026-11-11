/// Contract for website routes that do not exist on bahaa production yet.
/// See docs/customer-catalog-api.md. Calls return the server's real status;
/// a missing route is shown as unavailable and never as a successful order.
class CatalogContract {
  static const medicalDevices = '/api/v1/medical-devices';
  static String medicalDevice(int id) => '/api/v1/medical-devices/$id';
  static String medicalReportPayment(int id) =>
      '/api/v1/medical-devices/$id/report-payment';
  static String medicalPurchaseRequest(int id) =>
      '/api/v1/medical-devices/$id/purchase-request';
  static const creditProducts = '/api/v1/credit-products';
  static String creditRequest(int productId) =>
      '/api/v1/credit-requests/$productId';

  static const unavailable =
      'المسار غير موجود على خادم الموقع بعد. الشاشة لا تُكمل الطلب محليًا.';
}
