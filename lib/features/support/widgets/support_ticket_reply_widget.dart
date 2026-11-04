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
    return Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end:CrossAxisAlignment.start, children: [
      Container(margin: isMe ?  const EdgeInsets.fromLTRB(50, 5, 10, 5) : const EdgeInsets.fromLTRB(10, 5, 50, 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isMe ? const Radius.circular(10) : const Radius.circular(0),
          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(10),
          topRight: const Radius.circular(10)),
          color: isMe ? Theme.of(context).primaryColor.withValues(alpha:.1) : Theme.of(context).highlightColor),
          child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
              Text(dateTime, style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)
              ),

              message != null ?
              Text(message??'', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)) :
              const SizedBox.shrink()
            ]
          )
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
