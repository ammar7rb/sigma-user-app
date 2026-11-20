import 'package:flutter_sixvalley_ecommerce/data/model/image_full_url.dart';

class NotificationItemModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? newNotificationItem;
  List<NotificationItem>? notification;

  NotificationItemModel(
      {this.totalSize,
        this.limit,
        this.offset,
        this.newNotificationItem,
        this.notification});

  NotificationItemModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    newNotificationItem = json['new_notification'];
    if (json['notification'] != null) {
      notification = <NotificationItem>[];
      json['notification'].forEach((v) {
        notification!.add(NotificationItem.fromJson(v));
      });
    }
  }
}

class NotificationItem {
  int? id;
  String? sentBy;
  String? sentTo;
  String? title;
  String? description;
  int? notificationCount;
  String? image;
  ImageFullUrl? imageFullUrl;
  int? status;
  String? createdAt;
  String? updatedAt;
  NotificationSeenBy? seen;

  /// Server event key for payment and package notices (customer_event_key).
  String? eventKey;

  /// True for "payment accepted, order waits for a package" notices; tapping one
  /// opens the packages screen.
  bool get asksForPackage =>
      RegExp(r'^initial-order-\d+-requirements$').hasMatch(eventKey ?? '');


  NotificationItem(
      {this.id,
        this.sentBy,
        this.sentTo,
        this.title,
        this.description,
        this.notificationCount,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.seen,
        this.imageFullUrl
      });

  NotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sentBy = json['sent_by'];
    sentTo = json['sent_to'];
    title = json['title'];
    description = json['description'];
    notificationCount = int.parse(json['notification_count'].toString());
    image = json['image'];
    imageFullUrl = json['image_full_url'] != null
      ? ImageFullUrl.fromJson(json['image_full_url'])
      : null;
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    seen = json['notification_seen_by'] != null ? NotificationSeenBy.fromJson(json['notification_seen_by']) : null;
    eventKey = json['customer_event_key']?.toString();

  }
}

class NotificationSeenBy {
  int? id;
  int? userId;
  int? notificationId;
  String? createdAt;


  NotificationSeenBy(
      {this.id,
        this.userId,
        this.notificationId,
        this.createdAt,
        });

  NotificationSeenBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = int.parse(json['user_id'].toString());
    notificationId = int.parse(json['notification_id'].toString());
    createdAt = json['created_at'];
  }
}