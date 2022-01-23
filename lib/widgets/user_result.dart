import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/profile_screen.dart';

class UserResult extends StatefulWidget {
  late final User user;
  final Function updateFeed;

  UserResult(
    this.user,
    this.updateFeed,
  );

  @override
  State<UserResult> createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  Future<void> showProfile(BuildContext context,
      {required String profileId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profileId: profileId,
          hasBack: true,
        ),
      ),
    );
    if (result == 'profile') {
      widget.updateFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(
              context,
              profileId: widget.user.id,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage:
                    CachedNetworkImageProvider(widget.user.photoUrl),
              ),
              title: Text(
                widget.user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.user.username,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Divider(
            height: 2,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
