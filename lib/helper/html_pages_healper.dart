import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class HtmlPagesHelper {
  final splashController =
      Provider.of<SplashController>(Get.context!, listen: false);
  BusinessPageModel? get hasPrivacyPolicy {
    final pages = [
      ...?splashController.defaultBusinessPages,
      ...?splashController.businessPages,
    ];
    final combined = pages.where((page) => page.slug == 'terms-and-conditions');
    return combined.isEmpty ? null : combined.first;
  }
}
