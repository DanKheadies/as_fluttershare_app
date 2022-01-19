import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import './home.dart';
import './post_screen.dart';
import './profile.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({Key? key}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  late Future<List<ActivityFeedItem>> userNotifications;

  @override
  void initState() {
    super.initState();
    userNotifications = getActivityFeed();
  }

  Future<List<ActivityFeedItem>> getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser.id)
        .collection('feedItems')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(50)
        .get();

    List<ActivityFeedItem> feedItems = [];

    for (var item in snapshot.docs) {
      feedItems.add(ActivityFeedItem.fromDocument(item));
    }

    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: header(
        context,
        titleText: 'Activity Feed',
      ),
      body: FutureBuilder<List<ActivityFeedItem>>(
        future: userNotifications,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: snapshot.data!,
          );
        },
      ),
    );
  }
}

class ActivityFeedItem extends StatefulWidget {
  const ActivityFeedItem({
    Key? key,
    required this.username,
    required this.userId,
    required this.type,
    required this.mediaUrl,
    required this.postId,
    required this.userProfileImg,
    required this.commentData,
    required this.timestamp,
  }) : super(key: key);

  final String username;
  final String userId;
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
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  // Future<void> showProfile(BuildContext context,
  //     {required String profileId}) async {
  //   final derp = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Profile(
  //         profileId: profileId,
  //       ),
  //     ),
  //   );
  //   print('derp');
  //   print(derp);
  // }

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

  // Future<void> showProfile(BuildContext context,
  //     {required String profileId}) async {
  //   final derp = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Profile(
  //         profileId: profileId,
  //       ),
  //     ),
  //   );
  //   print('af derp');
  //   print(derp);
  // }
  void showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          profileId: profileId,
        ),
      ),
    ).then((value) => setState(() {}));
    print('af derp');
  }

  void showPost(context) {
    print('show post');
    print(widget.postId);
    print(widget.userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: widget.postId,
          userId: widget.userId,
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

  // Future showProfile(BuildContext context, {required String profileId}) async {
  //   final derp = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Profile(
  //         profileId: profileId,
  //       ),
  //     ),
  //   );
  //   print(derp);
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: widget.type != 'follow' ? () => showPost(context) : () {},
            child: RichText(
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
    );
  }
}

// showProfile(BuildContext context, {required String profileId}) async {
//   final derp = await Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => Profile(
//         profileId: profileId,
//       ),
//     ),
//   );
//   print(derp);
// }