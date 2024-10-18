class NotificationModel {
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.type,
    required this.title,
    required this.body,
    required this.data,
  });
}
