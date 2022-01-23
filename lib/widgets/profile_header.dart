import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare_app/widgets/progress.dart';

import '../models/user.dart';
import '../services/firebase_firestore.dart';
import '../widgets/count_column.dart';
import '../widgets/profile_button.dart';

FutureBuilder buildProfileHeader(
  BuildContext context,
  String profileId,
  String currentUserId,
  bool isFollowing,
  int postCount,
  int followerCount,
  int followingCount,
  Function editProfile,
  Function handleUnfollowUser,
  Function handleFollowUser,
) {
  return FutureBuilder(
    future: usersRef.doc(profileId).get(),
    builder: (contextr, snapshot) {
      if (!snapshot.hasData) {
        return circularProgress();
      }
      User user = User.fromDocument(snapshot.data);
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildCountColumn('posts', postCount),
                          buildCountColumn('followers', followerCount),
                          buildCountColumn('following', followingCount),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildProfileButton(
                            context,
                            profileId,
                            currentUserId,
                            isFollowing,
                            () => editProfile,
                            () => handleUnfollowUser,
                            () => handleFollowUser,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                user.bio,
              ),
            ),
          ],
        ),
      );
    },
  );
}
