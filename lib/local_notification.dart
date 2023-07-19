import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_message_model.dart';

class LocalNotificationService {
  static final LocalNotificationService _singleton =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _singleton;
  }

  LocalNotificationService._internal() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final darwinNotificationDetails = _createDarwinNotificationDetails();

    _platformChannelSpecifics = NotificationDetails(
      iOS: darwinNotificationDetails,
    );
  }

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late NotificationDetails _platformChannelSpecifics;
  Map<String, dynamic>? _unhandledNotificationPayload;

  Future<void> _requestIOSPermissions() async {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: false,
          sound: false,
        );
  }

  Future<void> showNotification(NotificationMessageModel message) async {
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.title,
      message.message,
      _platformChannelSpecifics,
      payload: jsonEncode(message.payload),
    );
  }

  Future<void> init() async {
    await _initializeNotificationPlugin();
    await _requestIOSPermissions();
    await _checkDidNotificationLaunchApp();
  }

  Future<void> _initializeNotificationPlugin() async {

    const iOSInitializationSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true, // check
    );

    const initializationSettings = InitializationSettings(
      iOS: iOSInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('FCM local notif onDidReceiveNotificationResponse');
        selectNotification(jsonDecode(response.payload ?? ''));
      },
    );
  }

  Future<void> handleUnhandledNotificationIfExist() async {
    if (_unhandledNotificationPayload != null) {
      selectNotification(_unhandledNotificationPayload!);
      _unhandledNotificationPayload = null;
    }
  }

  Future<void> _checkDidNotificationLaunchApp() async {
    final launchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      _unhandledNotificationPayload =
          jsonDecode(launchDetails.notificationResponse?.payload ?? '');
    }
  }

  Future selectNotification(Map<String, dynamic> payload) async {
    debugPrint("Push notification selected: $payload");
  }

  DarwinNotificationDetails _createDarwinNotificationDetails() =>
      const DarwinNotificationDetails();
}
