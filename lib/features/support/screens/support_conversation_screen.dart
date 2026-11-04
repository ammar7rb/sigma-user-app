import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/controllers/support_ticket_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/domain/models/support_ticket_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/widgets/support_ticket_reply_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

class SupportConversationScreen extends StatefulWidget {
  final SupportTicketModel supportTicketModel;
  const SupportConversationScreen(
      {super.key, required this.supportTicketModel});

  @override
  State<SupportConversationScreen> createState() =>
      _SupportConversationScreenState();
}

class _SupportConversationScreenState extends State<SupportConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _liveTimer;
  bool _refreshing = false;
  @override
  void initState() {
    super.initState();
    if (widget.supportTicketModel.purpose == 'account_activation') return;
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      _refreshConversation();
      _liveTimer = Timer.periodic(
          const Duration(seconds: 3), (_) => _refreshConversation());
    }
  }

  Future<void> _refreshConversation() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      await Provider.of<SupportTicketController>(context, listen: false)
          .getSupportTicketReplyList(context, widget.supportTicketModel.id);
    } finally {
      _refreshing = false;
    }
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.supportTicketModel.purpose == 'account_activation') {
      return Scaffold(
          appBar: CustomAppBar(title: 'الدعم'),
          body: const Center(child: Text('هذه المحادثة غير متاحة.')));
    }
    final title = widget.supportTicketModel.subject?.trim() ?? 'محادثة الدعم';
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body:
          Consumer<SupportTicketController>(builder: (context, support, child) {
        return Column(children: [
          Expanded(child: Consumer<SupportTicketController>(
              builder: (context, support, child) {
            return support.supportReplyList != null
                ? ListView.builder(
                    itemCount: support.supportReplyList!.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final reply = support.supportReplyList![index];
                      final isMe = reply.customerMessage != null ||
                          (reply.adminMessage == null && (int.tryParse(reply.adminId ?? '') ?? 0) == 0);
                      String? message = isMe
                          ? support.supportReplyList![index].customerMessage
                          : support.supportReplyList![index].adminMessage;
                      String dateTime = DateConverter.localDateToIsoStringAMPM(
                          DateTime.parse(
                              support.supportReplyList![index].createdAt!));
                      return SupportTicketReplyWidget(
                          message: message,
                          dateTime: dateTime,
                          isMe: isMe,
                          replyModel: support.supportReplyList![index]);
                    },
                  )
                : const Center(child: CircularProgressIndicator());
          })),
          support.pickedImageFileStored.isNotEmpty
              ? Container(
                  height: 72,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                      height: 62,
                                      width: 62,
                                      child: Image.file(
                                          File(support
                                              .pickedImageFileStored[index]
                                              .path),
                                          fit: BoxFit.cover)))),
                          Positioned(
                              right: 5,
                              child: InkWell(
                                  child: const Icon(Icons.cancel_outlined,
                                      color: Colors.red),
                                  onTap: () => support.pickMultipleImage(true,
                                      index: index)))
                        ]);
                      },
                      itemCount: support.pickedImageFileStored.length))
              : const SizedBox(),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                    top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: .55),
                )),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 54),
                padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(children: [
                  IconButton(
                    tooltip:
                        getTranslated('attach_image', context) ?? 'إرفاق صورة',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => support.pickMultipleImage(false),
                    icon: Icon(Icons.add_photo_alternate_outlined,
                        size: 21, color: Theme.of(context).primaryColor),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: TextField(
                        controller: _controller,
                        style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: getTranslated('write_here', context) ??
                                'Write here...',
                            hintStyle: titilliumRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeDefault),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 10),
                            border: InputBorder.none)),
                  )),
                  IconButton(
                    onPressed: support.isLoading ? null : () async {
                      final message = _controller.text.trim();
                      if (message.isEmpty && support.pickedImageFileStored.isEmpty) return;
                      try {
                        final response = await support.sendReply(widget.supportTicketModel.id, message);
                        if (!context.mounted) return;
                        if (response.statusCode == 200) {
                          if (_controller.text.trim() == message) _controller.clear();
                        } else {
                          showCustomSnackBarWidget('تعذر إرسال الرسالة، حاول مرة أخرى.', context);
                        }
                      } catch (_) {
                        if (context.mounted) showCustomSnackBarWidget('تعذر إرسال الرسالة، حاول مرة أخرى.', context);
                      }
                    },
                    icon: support.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.send_rounded,
                            color: Theme.of(context).primaryColor,
                            size: Dimensions.iconSizeDefault),
                  ),
                ]),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}
