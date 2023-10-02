import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/chat_user.dart';
import 'package:http/http.dart' as http;


class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> getDeviceToken(ChatUser chatUser) async {
    try {
      messaging.requestPermission();
      var token = await messaging.getToken();
      chatUser.pushToken = token!;
      print("Device Token $token");
    } catch (e) {
      print(e.toString());
    }
  }



  // send push Notification

  Future<void> sendPushNotification(ChatUser chatUser, String mesg, BuildContext context) async {
    try {
      final data = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": mesg,
        }
      };
      var response = http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
          'Key= AAAAR0bswnQ:APA91bGxHSI-rEHNptbqRUGLU09kcy8HNE5_Xr__EljfpPVTQAH_O1-xrNEEv74DwPjsTGzkyn714xTJD90lBoMui8pHfUXPFD7a6dJs_HzPCJdScumTQnWPx2J3PgCWzPnAEJ7qJCkr'
        },
        body: jsonEncode(data),
      ).then((value) {


      });
      print("Response $response");
    } catch (e) {
      print(e.toString());
    }
  }


}
