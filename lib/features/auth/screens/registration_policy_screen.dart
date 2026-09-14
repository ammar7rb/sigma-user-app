import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class RegistrationPolicyScreen extends StatelessWidget {
  final String title;
  final String content;
  final String? version;

  const RegistrationPolicyScreen({
    super.key,
    required this.title,
    required this.content,
    this.version,
  });

  String get _safeContent => content
      .replaceAll(
        RegExp(
          r'<\s*(script|style|iframe|object|embed|form)\b[^>]*>[\s\S]*?<\s*/\s*\1\s*>',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(
          r'<\s*(script|iframe|object|embed|form)\b[^>]*/?\s*>',
          caseSensitive: false,
        ),
        '',
      );

  @override
  Widget build(BuildContext context) {
    final trimmedVersion = version?.trim() ?? '';
    final unavailable = getTranslated('policy_content_unavailable', context) ??
        'Policy content is currently unavailable';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBar(title: title),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trimmedVersion.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: .08),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusHundred),
                        ),
                        child: Text(
                          '${getTranslated('policy_version', context) ?? 'Version'} $trimmedVersion',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],
                    if (_safeContent.trim().isEmpty)
                      Text(unavailable)
                    else
                      HtmlWidget(
                        _safeContent,
                        textStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.6,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
