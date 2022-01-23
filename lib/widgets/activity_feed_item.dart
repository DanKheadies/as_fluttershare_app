import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/post_screen.dart';
import '../screens/profile_screen.dart';

class ActivityFeedItem extends StatefulWidget {
  const ActivityFeedItem({
    Key? key,
    required this.username,
    required this.userId,
    required this.ownerId,
    required this.type,
    required this.mediaUrl,
    required this.postId,
    required this.userProfileImg,
    required this.commentData,
    required this.timestamp,
  }) : super(key: key);

  final String username;
  final String userId;
  final String ownerId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      ownerId: doc['ownerId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  State<ActivityFeedItem> createState() => _ActivityFeedItemState();
}

class _ActivityFeedItemState extends State<ActivityFeedItem> {
  String activityItemText = '';
  Widget mediaPreview() {
    return const SizedBox();
  }

  @override
  void initState() {
    configureMediaPreview();
    setActivityItemText();
    super.initState();
  }

  void showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profileId: profileId,
          hasBack: true,
        ),
      ),
    ).then((value) => setState(() {}));
  }

  void showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: widget.postId,
          userId: widget.ownerId,
        ),
      ),
    ).then((val) => setState(() {}));
  }

  Widget configureMediaPreview() {
    if (widget.type == 'like' || widget.type == 'comment') {
      return GestureDetector(
        onTap: () => showPost(context),
        child: SizedBox(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(widget.mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void setActivityItemText() {
    if (widget.type == 'like') {
      setState(() {
        activityItemText = 'liked your post.';
      });
    } else if (widget.type == 'follow') {
      setState(() {
        activityItemText = 'is following you.';
      });
    } else if (widget.type == 'comment') {
      setState(() {
        activityItemText = 'replied: ${widget.commentData}';
      });
    } else {
      setState(() {
        activityItemText = 'Error (unknown type): ${widget.type}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.type != 'follow' ? () => showPost(context) : () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.white54,
          child: ListTile(
            title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: widget.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $activityItemText',
                  ),
                ],
              ),
            ),
            leading: GestureDetector(
              onTap: () => showProfile(
                context,
                profileId: widget.userId,
              ),
              child: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.userProfileImg),
              ),
            ),
            subtitle: Text(
              timeago.format(widget.timestamp.toDate()),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: configureMediaPreview(),
          ),
        ),
      ),
    );
  }
}
