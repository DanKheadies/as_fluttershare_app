import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import './google_signin.dart';

late FirebaseMessaging firebaseMessaging;

void firebaseMessagesSetup(
  BuildContext context,
  FirebaseMessaging _firebaseMessaging,
) {
  FirebaseMessaging.onMessage.listen((message) {
    // print('message received');
    // print(message.notification!.body);
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text("Notification"),
    //         content: Text(message.notification!.body!),
    //         actions: [
    //           TextButton(
    //             child: const Text("Ok"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           )
    //         ],
    //       );
    //     });
    print('on message: $message\n');
    final String receipientId = message.data['recipient'];
    final String? body = message.notification!.body;
    final dynamic values = message.data.values;
    print(values);
    print(receipientId);
    print(currentUser.id);
    if (receipientId == currentUser.id) {
      print('Notification shown!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            body!,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      print('Notification NOT shown.');
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('message clicked!');
  });

  // _firebaseMessaging.subscribeToTopic(topic)

  if (Platform.isIOS) getiOSPermission(_firebaseMessaging);
}

Future<void> getiOSPermission(
  FirebaseMessaging _firebaseMessaging,
) async {
  _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //   print('User granted permission');
  // } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  //   print('User granted provisional permission');
  // } else {
  //   print('User declined or has not accepted permission');
  // }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}
