import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/firebase_firestore.dart';
import '../services/google_signin.dart';
import '../widgets/progress.dart';
import '../widgets/user_result.dart';

Widget buildUsersToFollow(
  List<String> followingList,
  Function updateFeed,
) {
  return StreamBuilder<QuerySnapshot>(
    stream: usersRef
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(30)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }

      List<UserResult> userResults = [];
      for (var doc in snapshot.data!.docs) {
        User user = User.fromDocument(doc);
        final bool isAuthUser = currentUser.id == user.id;
        final bool isFollowingUser = followingList.contains(user.id);

        if (isAuthUser) {
          // print('is auth user');
        } else if (isFollowingUser) {
          // print('is following user');
        } else {
          UserResult userResult = UserResult(user, updateFeed);
          userResults.add(userResult);
        }
      }
      return Container(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Users to Follow',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: userResults,
            ),
          ],
        ),
      );
    },
  );
}
