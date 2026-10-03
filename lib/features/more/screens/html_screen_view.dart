import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlViewScreen extends StatelessWidget {
  final BusinessPageModel? page;
  const HtmlViewScreen({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocalizationController>().locale.languageCode;
    return Scaffold(backgroundColor: Theme.of(context).cardColor,
      body: Column(children: [
          CustomAppBar(title: page?.localizedTitle(language) ?? ''),
          Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const BouncingScrollPhysics(),
            child:  Column(
              children: [

                const SizedBox(height: Dimensions.paddingSizeSmall),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: SizedBox(
                      height: 70,
                      width: double.infinity,
                      child: CustomImageWidget(
                        fit: BoxFit.cover,
                        image: page?.bannerFullUrl?.path ?? "",
                      ),
                    ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                HtmlWidget(page?.localizedDescription(language) ?? '',
                  onTapUrl: (String url) {
                    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                  textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
