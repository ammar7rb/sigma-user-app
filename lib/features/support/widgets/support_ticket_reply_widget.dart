import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/domain/models/message_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/widgets/message_bubble_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/domain/models/support_reply_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SupportTicketReplyWidget extends StatelessWidget {
  final bool isMe;
  final String dateTime;
  final String? message;
  final SupportReplyModel replyModel;
  const SupportTicketReplyWidget({super.key, required this.isMe, required this.dateTime, this.message, required this.replyModel});

  @override
  Widget build(BuildContext context) {
    final files = (replyModel.attachmentFullUrl ?? []).where((item) => _privateReport(item.path) != null).toList();
    final images = (replyModel.attachmentFullUrl ?? []).where((item) => _privateReport(item.path) == null).toList();
    final theme = Theme.of(context);
    final text = (message ?? '').trim();
    final rtlText = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    // Own messages are filled with the brand colour; support replies are outlined cards.
    final radius = BorderRadiusDirectional.only(
      topStart: const Radius.circular(16), topEnd: const Radius.circular(16),
      bottomStart: Radius.circular(isMe ? 16 : 5), bottomEnd: Radius.circular(isMe ? 5 : 16));
    return Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end:CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
        child: Text(getTranslated(isMe ? 'support_chat_you' : 'support_chat_team', context) ?? '', style: textRegular.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: theme.hintColor)),
      ),
      if (text.isNotEmpty)
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: isMe ? theme.primaryColor : theme.cardColor,
              border: isMe ? null : Border.all(color: theme.dividerColor),
              boxShadow: const [BoxShadow(color: Color(0x0F172942), blurRadius: 2, offset: Offset(0, 1))],
            ),
            child: SelectableText(text,
              textDirection: rtlText ? TextDirection.rtl : TextDirection.ltr,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.6,
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color)),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 3, 14, 4),
        child: Text(dateTime, textDirection: TextDirection.ltr, style: textRegular.copyWith(fontSize: 11, color: theme.hintColor)),
      ),

      for (final file in files)
        TextButton.icon(onPressed: () => _openReport(context, file.path, file.key), icon: const Icon(Icons.description_outlined), label: Text(file.key ?? 'فتح التقرير الفني')),
      if(images.isNotEmpty)
        const SizedBox(height: Dimensions.paddingSizeSmall),

      images.isNotEmpty?
      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Directionality(textDirection:Provider.of<LocalizationController>(context, listen: false).isLtr ? isMe ?
        TextDirection.rtl : TextDirection.ltr : isMe ? TextDirection.ltr : TextDirection.rtl,
          child: MediaGridWidget(
            images: images.map((attachment) {
              return  Attachment(
                type: 'image',
                key: attachment.key,
                path: attachment.path,
                size: '',
              );
            }).toList(),
            isMe: isMe
          ),
        ),
      ):
      const SizedBox.shrink(),
    ],
    );
  }

  RegExpMatch? _privateReport(String? value) {
    final path = Uri.tryParse(value ?? '')?.path ?? '';
    return RegExp(r'^/support-ticket/(\d+)/attachments/(\d+)/(\d+)/download$').firstMatch(path);
  }

  Future<void> _openReport(BuildContext context, String? url, String? originalName) async {
    final match = _privateReport(url);
    if (match == null) return;
    final extension = (originalName ?? '').split('.').last.toLowerCase();
    if (!['pdf', 'doc', 'docx'].contains(extension)) return;
    try {
      final response = await di.sl<DioClient>().get('/api/v1/customer/support-ticket/${match[1]}/attachments/${match[2]}/${match[3]}/download', options: Options(responseType: ResponseType.bytes));
      final bytes = response.data as List<int>;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/medical_report_${match[2]}_${match[3]}.$extension');
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) throw Exception('open failed');
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح التقرير، حاول مرة أخرى.')));
    }
  }
}
