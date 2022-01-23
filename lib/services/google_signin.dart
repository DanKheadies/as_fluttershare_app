import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './firebase_firestore.dart';
import '../models/user.dart';
import '../screens/create_account_screen.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
late User currentUser;

void checkGoogleAuthentication(
  BuildContext context,
  bool isAuthenicated,
  FirebaseMessaging firebaseMessaging,
  Function isAuthenticated,
  Function isNotAuthenticated,
  Function resetPage,
) {
  if (!isAuthenicated) {
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(
        context,
        firebaseMessaging,
        account,
        isAuthenticated,
        isNotAuthenticated,
        resetPage,
      );
    }).catchError((err) {
      print('Error signing in: $err');
    }).then(
      (_) => {
        // if (!isAuth)
        //   {
        googleSignIn.onCurrentUserChanged.listen((account) {
          handleSignIn(
            context,
            firebaseMessaging,
            account,
            isAuthenticated,
            isNotAuthenticated,
            resetPage,
          );
        }, onError: (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error signing in: $err'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
        })
        // }
      },
    );
  }
}

Future<void> handleSignIn(
  BuildContext context,
  FirebaseMessaging firebaseMessaging,
  GoogleSignInAccount? account,
  Function isAuthed,
  Function isNotAuthed,
  Function resetPage,
) async {
  if (account != null) {
    await createUserInFirebase(
      context,
      firebaseMessaging,
    );
    isAuthed();
  } else {
    isNotAuthed();
  }

  resetPage();
}

Future<void> createUserInFirebase(
  BuildContext context,
  FirebaseMessaging firebaseMessaging,
) async {
  final GoogleSignInAccount? user = googleSignIn.currentUser;
  DocumentSnapshot doc = await usersRef.doc(user?.id).get();

  if (!doc.exists) {
    final username = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAccountScreen(),
      ),
    );

    usersRef.doc(user?.id).set({
      'id': user!.id,
      'username': username,
      'photoUrl': user.photoUrl,
      'email': user.email,
      'displayName': user.displayName,
      'bio': '',
      'timestamp': getNow(),
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

  firebaseMessaging.getToken().then((token) {
    print('Firebase Messaging Token: $token\n');
    usersRef.doc(user!.id).update({'androidNotificationToken': token});
  });
  firebaseMessaging.onTokenRefresh.listen((token) {
    print('NEW Firebase Messaging Token: $token\n');
    usersRef.doc(user!.id).update({'androidNotificationToken': token});
  });
}
