import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import './screens/home_screen.dart';
import './screens/post_screen.dart';
import './screens/profile_screen.dart';
import './services/firebase_messaging.dart';
import './services/google_signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Something went wrong.');
          return const SizedBox();
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        return MaterialApp(
          title: 'FlutterShare',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.deepPurple,
              secondary: Colors.teal,
            ),
          ),
          home: const HomeScreen(),
          routes: {
            HomeScreen.id: (ctx) => const HomeScreen(),
            PostScreen.id: (ctx) => PostScreen(
                  postId: '',
                  userId: currentUser.id,
                ),
            ProfileScreen.id: (ctx) => ProfileScreen(
                  profileId: currentUser.id,
                  hasBack: false,
                ),
          },
        );
      },
    );
  }
}
