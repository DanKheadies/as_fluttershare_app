import 'package:flutter/material.dart';

import '../widgets/button.dart';

Widget buildProfileButton(
  BuildContext context,
  String profileId,
  String currentUserId,
  bool isFollowing,
  Function editProfile,
  Function handleUnfollowUser,
  Function handleFollowUser,
) {
  bool isProfileOwner = currentUserId == profileId;
  if (isProfileOwner) {
    return buildButton(
      context,
      'Edit Profile',
      isFollowing,
      editProfile(),
    );
  } else if (isFollowing) {
    return buildButton(
      context,
      'Unfollow',
      isFollowing,
      handleUnfollowUser(),
    );
  } else if (!isFollowing) {
    return buildButton(
      context,
      'Follow',
      isFollowing,
      handleFollowUser(),
    );
  } else {
    return const SizedBox();
  }
}
