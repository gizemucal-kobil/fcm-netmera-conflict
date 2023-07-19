import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

import 'local_notification.dart';
import 'notification_message_model.dart';

class FirebasePushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static final FirebasePushNotificationService _singleton = FirebasePushNotificationService._internal();

  factory FirebasePushNotificationService() {
    return _singleton;
  }

  FirebasePushNotificationService._internal();

  Future initialize() async {
    NotificationSettings settings = await _fcm.requestPermission();
    _handlePermissionResult(settings);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _fcm.getToken().then(_handleToken);
    _fcm.getInitialMessage().then(_handleInitialNotification);

    _setListeners();
    debugPrint('FCM initialized');
  }

  FutureOr<void> _handlePermissionResult(settings) {
    debugPrint('FCM User granted permission: ${settings.authorizationStatus}');
  }

  void _setListeners() {
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('FCM onMessageOpenedApp');

    bool handled = _netmeraMessageHandler(message);

    if (!handled) {
      onMessageOpenedApp(message.toPushNotificationMessage());
    }
  }

  void _onMessage(RemoteMessage message) {
    debugPrint('FCM onMessage');

    bool handled = _netmeraMessageHandler(message);

    if (!handled) {
      onForegroundMessage(message.toPushNotificationMessage());
    }
  }

  FutureOr<void> _handleToken(token) {
    Netmera.onNetmeraNewToken(token);
    debugPrint("FCM FirebaseMessaging token: $token");
  }

  FutureOr<void> _handleInitialNotification(RemoteMessage? message) {
    if (message != null) {
      debugPrint('FCM getInitialMessage');
      onMessageOpenedApp(message.toPushNotificationMessage());
    }
  }

  void onForegroundMessage(NotificationMessageModel message) {
    debugPrint('Push notification received in the foreground');
    _handleForegroundMessage(message);
  }

  void _handleForegroundMessage(NotificationMessageModel message) {
      _showNotification(message);
  }

  void onMessageOpenedApp(NotificationMessageModel message) {
    LocalNotificationService().selectNotification(message.payload);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint('FCM onBackgroundMessage');

  bool handled = _netmeraMessageHandler(message);

  if (!handled) {
    onBackgroundMessage(message.toPushNotificationMessage());
  }
}

bool _netmeraMessageHandler(RemoteMessage message) {
  bool shouldBeHandledByNetmera = Netmera.isNetmeraRemoteMessage(message.data);
  if (shouldBeHandledByNetmera) {
    debugPrint("Received Netmera push. Sending it to Netmera");
    Netmera.onNetmeraFirebasePushMessageReceived(message.from, message.data);
  } else {
    debugPrint("Not a Netmera push. SuperApp will handle it");
  }

  return shouldBeHandledByNetmera;
}

extension RemoteMessageExtension on RemoteMessage {
  NotificationMessageModel toPushNotificationMessage() {
    String? title =
        (data['title'] ?? notification?.title) ?? (notification?.titleLocKey);
    String message = (data['message'] ?? notification?.body);

    return NotificationMessageModel(
      title: title,
      message: message,
      payload: data,
    );
  }
}

void onBackgroundMessage(NotificationMessageModel message) {
  debugPrint('Push notification received in the background');
  _handleBackgroundMessage(message);
}

Future<void> _handleBackgroundMessage(NotificationMessageModel message) async {
  // _showNotification(message);
}

Future<void> _showNotification(NotificationMessageModel message) async {
  LocalNotificationService().showNotification(message);
}
