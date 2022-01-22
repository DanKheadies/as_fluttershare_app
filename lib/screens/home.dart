import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './activity_feed.dart';
import './create_account.dart';
import './profile.dart';
import './search.dart';
import './timeline.dart';
import './upload.dart';

import '../models/user.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final firebase_storage.FirebaseStorage storageRef =
    firebase_storage.FirebaseStorage.instance;
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final postsRef = FirebaseFirestore.instance.collection('posts');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
late User currentUser;

// TODOS:
// Deleting a Post & removing the 'Back' button
// Refresthing a Screen:
//  - Activity Feed after (un)following someone (and going back)
//  - Deleting a post (see above)
//  - Pulling down user profile
// Showing Comment count (on post)
// Log out -> Log in tab selected icon
// Disable Post button while uploading (and get location and editing text)

class Home extends StatefulWidget {
  static const String id = 'home';

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  bool isSignedIn = false;
  int pageIndex = 0;
  late FirebaseMessaging _firebaseMessaging;
  late PageController pageController;

  @override
  void initState() {
    print('init');
    pageController = PageController();
    currentUser = User(
      id: '',
      email: '',
      username: '',
      photoUrl: '',
      displayName: '',
      bio: '',
    );

    firebaseMessagesSetup();

    if (!isAuth) {
      googleSignIn.signInSilently(suppressErrors: false).then((account) {
        handleSignIn(account);
      }).catchError((err) {
        print('Error signing in: $err');
      });
    }

    if (!isAuth) {
      googleSignIn.onCurrentUserChanged.listen((account) {
        handleSignIn(account);
      }, onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error signing in: $err'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void firebaseMessagesSetup() {
    _firebaseMessaging = FirebaseMessaging.instance;

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

    if (Platform.isIOS) getiOSPermission();
  }

  handleSignIn(GoogleSignInAccount? account) async {
    if (account != null) {
      await createUserInFirebase();

      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  // configurePushNotifications() async {
  //   final GoogleSignInAccount? user = googleSignIn.currentUser;
  //   if (Platform.isIOS) getiOSPermission();

  //   _firebaseMessaging.getToken().then((token) {
  //     print('Firebase Messaging Token: $token\n');
  //     usersRef.doc(user!.id).update({'androidNotificationToken': token});
  //   });

  //   FirebaseMessaging.onMessage.listen((message) {
  //     print('on message: $message\n');
  //     final String receipientId = message.data['recipient'];
  //     final String? body = message.notification!.body;
  //     print(receipientId);
  //     print(currentUser.id);
  //     if (receipientId == currentUser.id) {
  //       print('Notification shown!');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             body!,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //       );
  //     } else {
  //       print('Notification NOT shown.');
  //     }
  //   });
  // }

  getiOSPermission() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> createUserInFirebase() async {
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user?.id).get();

    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateAccount(),
        ),
      );

      usersRef.doc(user?.id).set({
        'id': user!.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp,
      });

      // make new user their own follower (to get own posts)
      // await followersRef
      //     .doc(user.id)
      //     .collection('userFollowers')
      //     .doc(user.id)
      //     .set({});

      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);

    _firebaseMessaging.getToken().then((token) {
      print('Firebase Messaging Token: $token\n');
      usersRef.doc(user!.id).update({'androidNotificationToken': token});
    });
    _firebaseMessaging.onTokenRefresh.listen((token) {
      print('NEW Firebase Messaging Token: $token\n');
      usersRef.doc(user!.id).update({'androidNotificationToken': token});
    });
  }

  void login() {
    googleSignIn.signIn();
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(currentUser: currentUser),
          const ActivityFeed(),
          Upload(currentUser: currentUser),
          const Search(),
          Profile(profileId: currentUser.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.whatshot,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.primary,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            RawMaterialButton(
              onPressed: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
