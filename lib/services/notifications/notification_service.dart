// Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hand_in_need/services/notifications/fields.dart';
// Util
import 'package:http/http.dart' as http;
import 'device_tokens.dart';
import 'dart:convert';
import 'dart:async';


class NotificationService {
  static final _shared = NotificationService._sharedInstance();
  NotificationService._sharedInstance();
  factory NotificationService() => _shared;

  static StreamSubscription? _streamSubscription;
  final db = FirebaseFirestore.instance.collection('user_tokens');
  final notifiationsPlugin = FlutterLocalNotificationsPlugin();
  final messaging = FirebaseMessaging.instance;

  Future<void> updateDeviceTokens(String userId) async {
    final userTokensQuery = await db
        .where(
          userIdField,
          isEqualTo: userId,
        )
        .get();
    final userTokens = userTokensQuery.docs.isEmpty
        ? await db.add({
            userIdField: userId,
            tokensField: [],
          })
        : userTokensQuery.docs[0].reference;
    final token = await FirebaseMessaging.instance.getToken();
    userTokens.update({
      tokensField: FieldValue.arrayUnion([token!]),
    });
    _streamSubscription?.cancel();
    _streamSubscription = null;

    _streamSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {
        userTokens.update({
          tokensField: FieldValue.arrayUnion([token])
        });
      },
    );
  }

  Future<void> sendMessageToUser(
      {required String userId, required String signupId}) async {
    final userDeviceTokens = await _getDeviceTokenByUserId(userId);

    for (String deviceToken in userDeviceTokens.tokens) {
      try {
        await http.post(
          Uri.parse('https://us-central1-hand-in-need.cloudfunctions.net/sendNotification'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'deviceToken': deviceToken, 'signupId': signupId}),
        );
      } catch (e) {
        // Invalid token
      }
    }
  }

  Future<void> requestPermisstions() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.notDetermined) {
      return;
    }
    await messaging.requestPermission();
  }

  Future<void> initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await notifiationsPlugin.initialize(
      initSettings,
    );
  }

  Future<DeviceTokens> _getDeviceTokenByUserId(String userId) async {
    final userTokensQuery = await db
        .where(
          userIdField,
          isEqualTo: userId,
        )
        .get();
    if (userTokensQuery.docs.isEmpty) {
      final newInstance = await db.add({
        userIdField: userId,
        tokensField: [],
      });
      return DeviceTokens(id: newInstance.id, userId: userId, tokens: []);
    }
    return DeviceTokens.fromFirebase(userTokensQuery.docs[0]);
  }

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
