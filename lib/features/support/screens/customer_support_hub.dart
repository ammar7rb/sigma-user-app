import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/domain/models/support_ticket_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/screens/support_conversation_screen.dart';

class SupportTicketScreen extends StatefulWidget {
  final bool isBackButtonExist, fromDashboard;
  const SupportTicketScreen(
      {super.key, this.isBackButtonExist = true, this.fromDashboard = false});
  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  List<SupportTicketModel>? conversations;
  String? error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final response =
          await di.sl<DioClient>().get(AppConstants.getSupportTicketUri);
      if (mounted) {
        setState(() {
          conversations = (response.data as List)
              .map((row) =>
                  SupportTicketModel.fromJson(Map<String, dynamic>.from(row)))
              .toList();
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => error = 'تعذر تحميل المحادثات. سجّل الدخول أو أعد المحاولة.');
      }
    }
  }

  Future<void> report() async {
    if (busy) return;
    final text = TextEditingController();
    final message = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('الإبلاغ عن مشكلة'),
                content: TextField(
                    controller: text,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 5000,
                    decoration: const InputDecoration(
                        labelText: 'اكتب ما حدث وكيف يمكننا مساعدتك')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء')),
                  FilledButton(
                      onPressed: () {
                        if (text.text.trim().length >= 3) {
                          Navigator.pop(ctx, text.text.trim());
                        }
                      },
                      child: const Text('إرسال إلى الدعم'))
                ]));
    text.dispose();
    if (!mounted || message == null) return;
    setState(() => busy = true);
    try {
      final response = await di
          .sl<DioClient>()
          .post('/api/v1/customer/support/reports', data: {'message': message});
      if (mounted) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SupportConversationScreen(
                    supportTicketModel: SupportTicketModel.fromJson(
                        Map<String, dynamic>.from(
                            response.data['conversation'])))));
      }
      await load();
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر إرسال المشكلة. أعد المحاولة.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('التواصل مع الدعم'),
          automaticallyImplyLeading:
              widget.isBackButtonExist && !widget.fromDashboard),
      body: RefreshIndicator(
          onRefresh: load,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            if (error != null) ...[
              Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              TextButton(onPressed: load, child: const Text('إعادة المحاولة'))
            ],
            if (conversations == null && error == null)
              const Center(child: CircularProgressIndicator()),
            if (conversations?.isEmpty == true)
              const Text('ستظهر محادثتك هنا بعد إرسال المشكلة.'),
            for (final conversation in conversations ?? <SupportTicketModel>[])
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(conversation.purpose == 'account_activation'
                      ? 'تفعيل الحساب'
                      : conversation.subject ?? 'محادثة الدعم'),
                  subtitle: Text(conversation.updatedAt ?? ''),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SupportConversationScreen(
                              supportTicketModel: conversation)))),
          ])),
      bottomNavigationBar: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                  onPressed: busy ? null : report,
                  child: Text(busy ? 'جاري الإرسال' : 'الإبلاغ عن مشكلة')))));
}
