import 'dart:async';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/support/domain/models/support_ticket_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';

String communicationLabel(BuildContext context, String type) {
  final arabic = Directionality.of(context) == TextDirection.rtl;
  return type == 'messages'
      ? (arabic ? 'الرسائل' : 'Messages')
      : (arabic ? 'الإشعارات' : 'Notifications');
}

void openCommunicationItem(Map<String, dynamic> item) {
  final target = item['target'];
  if (target is! Map) return;
  final id = int.tryParse('${target['id']}');
  if (id == null) return;
  if (target['type'] == 'subscription' && Get.context != null) {
    Navigator.of(Get.context!).push(MaterialPageRoute<void>(
        builder: (_) => const MonthlySubscriptionScreen()));
  } else if (target['type'] == 'order') {
    RouterHelper.getOrderDetailsScreenRoute(
        action: RouteAction.push, orderId: id, isNotification: true);
  } else if (target['type'] == 'message') {
    RouterHelper.getSupportConversationRoute(
        action: RouteAction.push,
        supportTicketModel: SupportTicketModel(
            id: id,
            subject: '${item['title']}',
            status: item['status'],
            purpose: item['purpose'],
            description: '${item['description']}'));
  }
}

class CustomerCommunicationHeader extends StatefulWidget {
  final Color? color;
  const CustomerCommunicationHeader({super.key, this.color});
  @override
  State<CustomerCommunicationHeader> createState() =>
      _CustomerCommunicationHeaderState();
}

class _CustomerCommunicationHeaderState
    extends State<CustomerCommunicationHeader> with WidgetsBindingObserver {
  Timer? timer;
  Map<String, int> totals = {};
  bool busy = false;
  bool visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent != false) refresh();
    });
  }

  Future<void> refresh() async {
    if (busy || !visible) return;
    busy = true;
    try {
      final response =
          await di.sl<DioClient>().get('/api/v1/customer/communication');
      if (mounted) {
        setState(() {
          totals = {
            for (final type in ['messages', 'notifications'])
              type: (response.data[type]['total'] as num).toInt()
          };
        });
      }
    } catch (_) {
      // Preview and full-page views offer a visible error and retry action.
    } finally {
      busy = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    visible = state == AppLifecycleState.resumed;
    if (visible) refresh();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> preview(String type) async {
    final direction = Directionality.of(context);
    await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => Directionality(
            textDirection: direction,
            child: FractionallySizedBox(
                heightFactor: .65,
                child: CustomerCommunicationPage(type: type, preview: true))));
  }

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        for (final type in ['messages', 'notifications'])
          IconButton(
              tooltip:
                  '${communicationLabel(context, type)} (${totals[type] ?? 0})',
              color: widget.color,
              onPressed: () => preview(type),
              icon: Badge(
                  isLabelVisible: (totals[type] ?? 0) > 0,
                  label: Text((totals[type] ?? 0) > 99
                      ? '99+'
                      : '${totals[type] ?? 0}'),
                  child: Icon(type == 'messages'
                      ? Icons.chat_bubble_outline_rounded
                      : Icons.notifications_none_rounded))),
      ]);
}

class CustomerCommunicationPage extends StatefulWidget {
  final String type;
  final bool preview;
  const CustomerCommunicationPage(
      {super.key, required this.type, this.preview = false});
  @override
  State<CustomerCommunicationPage> createState() =>
      _CustomerCommunicationPageState();
}

class _CustomerCommunicationPageState extends State<CustomerCommunicationPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>>? items;
  Timer? timer;
  bool busy = false;
  bool failed = false;
  bool visible = true;
  int page = 1;
  int lastPage = 1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent != false) load();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    visible = state == AppLifecycleState.resumed;
    if (visible) load();
  }

  Future<void> load() async {
    if (busy || !visible) return;
    setState(() => busy = true);
    try {
      final query = widget.preview ? '' : '?type=${widget.type}&page=$page';
      final response =
          await di.sl<DioClient>().get('/api/v1/customer/communication$query');
      final body = Map<String, dynamic>.from(response.data);
      final rows = widget.preview ? body[widget.type]['items'] : body['items'];
      if (mounted) {
        setState(() {
          items = (rows as List)
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
          lastPage = widget.preview ? 1 : (body['last_page'] as num).toInt();
          failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = Directionality.of(context) == TextDirection.rtl;
    final label = communicationLabel(context, widget.type);
    final content = Column(children: [
      if (widget.preview)
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(children: [
              Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleLarge)),
              TextButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    final direction = Directionality.of(context);
                    navigator.pop();
                    navigator.push(MaterialPageRoute(
                        builder: (_) => Directionality(
                            textDirection: direction,
                            child:
                                CustomerCommunicationPage(type: widget.type))));
                  },
                  child: Text(arabic ? 'عرض الكل' : 'View all'))
            ])),
      if (failed)
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                  child: Text(arabic
                      ? 'تعذر تحميل التحديثات.'
                      : 'Could not load updates.')),
              TextButton(
                  onPressed: load,
                  child: Text(arabic ? 'إعادة المحاولة' : 'Retry'))
            ])),
      Expanded(
          child: RefreshIndicator(
              onRefresh: load,
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (items == null && !failed)
                      const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator())),
                    if (items?.isEmpty == true)
                      Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(arabic
                              ? 'لا توجد عناصر حالياً.'
                              : 'No items yet.')),
                    for (final item in items ?? <Map<String, dynamic>>[])
                      ListTile(
                          leading: Icon(widget.type == 'messages'
                              ? Icons.chat_bubble_outline_rounded
                              : Icons.notifications_none_rounded),
                          title: Text('${item['title']}'),
                          subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item['description']}'),
                                if (item['created_at'] != null)
                                  Text(_date('${item['created_at']}'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                              ]),
                          onTap: item['target'] == null
                              ? null
                              : () {
                                  if (widget.preview) Navigator.pop(context);
                                  openCommunicationItem(item);
                                }),
                  ]))),
      if (!widget.preview && lastPage > 1)
        SafeArea(
            top: false,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: page > 1 && !busy
                          ? () {
                              setState(() {
                                page--;
                                items = null;
                              });
                              load();
                            }
                          : null,
                      child: Text(arabic ? 'السابق' : 'Previous')),
                  Text('$page / $lastPage'),
                  TextButton(
                      onPressed: page < lastPage && !busy
                          ? () {
                              setState(() {
                                page++;
                                items = null;
                              });
                              load();
                            }
                          : null,
                      child: Text(arabic ? 'التالي' : 'Next')),
                ])),
    ]);
    return widget.preview
        ? content
        : Scaffold(appBar: AppBar(title: Text(label)), body: content);
  }

  String _date(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return '';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
