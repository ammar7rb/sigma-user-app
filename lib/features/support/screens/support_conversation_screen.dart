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
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
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
  bool _activationHandled = false;
  bool _refreshing = false;
  @override
  void initState() {
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<SupportTicketController>(context, listen: false)
          .getSupportTicketReplyList(context, widget.supportTicketModel.id);
      _liveTimer = Timer.periodic(
          const Duration(seconds: 3), (_) => _refreshActivationConversation());
    }
    super.initState();
  }

  Future<void> _refreshActivationConversation() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      await Provider.of<SupportTicketController>(context, listen: false)
          .getSupportTicketReplyList(context, widget.supportTicketModel.id);
    } finally {
      _refreshing = false;
    }
    if (widget.supportTicketModel.purpose != 'account_activation' ||
        _activationHandled ||
        !mounted) {
      return;
    }
    await Provider.of<ProfileController>(context, listen: false)
        .getUserInfo(context);
    if (!mounted) {
      return;
    }
    final active = Provider.of<ProfileController>(context, listen: false)
            .userInfoModel
            ?.activation
            ?.isActive ==
        true;
    if (active && mounted) {
      _activationHandled = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم تفعيل حسابك بنجاح'),
        backgroundColor: Color(0xFF11875D),
      ));
      RouterHelper.getDashboardRoute(
          action: RouteAction.pushNamedAndRemoveUntil, page: 'home');
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
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.supportTicketModel.subject,
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
                      bool isMe = (support.supportReplyList![index].adminId !=
                              '1' ||
                          support.supportReplyList![index].customerMessage !=
                              null);
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
                  height: 90,
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
                                      height: 80,
                                      width: 80,
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
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsetsDirectional.only(start: 14, end: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(top: 5),
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
                            border: InputBorder.none,
                            suffixIcon: InkWell(
                                onTap: () => support.pickMultipleImage(false),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(Images.attachment))))),
                  )),
                  IconButton(
                    onPressed: () {
                      if (_controller.text.isEmpty &&
                          support.pickedImageFileStored.isEmpty) {
                      } else {
                        support.sendReply(
                            widget.supportTicketModel.id, _controller.text);
                        _controller.text = '';
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
