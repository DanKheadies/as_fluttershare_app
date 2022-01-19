import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './screens/home.dart';
import './screens/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return MaterialApp(
      title: 'FlutterShare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.deepPurple,
          secondary: Colors.teal,
        ),
      ),
      home: const Home(),
      routes: {
        Home.id: (ctx) => const Home(),
        Profile.id: (ctx) => Profile(profileId: currentUser.id),
      },
    );
  }
}
