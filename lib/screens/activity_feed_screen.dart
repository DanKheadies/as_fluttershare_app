import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firebase_firestore.dart';
import '../services/google_signin.dart';
import '../widgets/activity_feed_item.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({Key? key}) : super(key: key);

  @override
  _ActivityFeedScreenState createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
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
