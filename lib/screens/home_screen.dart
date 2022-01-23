import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/firebase_messaging.dart';
import '../services/google_signin.dart';
import '../widgets/auth.dart';
import '../widgets/unAuth.dart';

// TODOS:
// Push notifications on iOS
// Refresthing a Screen:
//  - Activity Feed after (un)following someone (and going back)

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAuth = false;
  bool isSignedIn = false;
  int pageIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    currentUser = User(
      id: '',
      email: '',
      username: '',
      photoUrl: '',
      displayName: '',
      bio: '',
    );

    firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessagesSetup(
      context,
      firebaseMessaging,
    );

    checkGoogleAuthentication(
      context,
      isAuth,
      firebaseMessaging,
      isAuthenticated,
      isNotAuthenticated,
      resetPage,
    );

    super.initState();
  }

  void isAuthenticated() {
    setState(() {
      isAuth = true;
    });
  }

  void isNotAuthenticated() {
    setState(() {
      isAuth = false;
    });
  }

  void resetPage() {
    setState(() {
      pageIndex = 0;
    });
  }

  void onPageChanged(int _pageIndex) {
    setState(() {
      pageIndex = _pageIndex;
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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth
        ? Auth(
            currentUser: currentUser,
            pageController: pageController,
            pageIndex: pageIndex,
            navHandler: onTap,
            onPageChanged: onPageChanged,
          )
        : UnAuth(
            loginHandler: googleSignIn.signIn,
          );
  }
}
