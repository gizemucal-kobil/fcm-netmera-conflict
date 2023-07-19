class NotificationMessageModel {
  const NotificationMessageModel({
    this.title,
    this.message,
    this.payload = const <String, dynamic>{},
  });

  final String? title;
  final String? message;
  final Map<String, dynamic> payload;
}
