import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './home.dart';
import './search.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';

class Timeline extends StatefulWidget {
  const Timeline({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool gettingData = false;
  List<Post> posts = [];
  List<String> followingList = [];

  @override
  void initState() {
    setState(() {
      gettingData = true;
    });
    getTimeline();
    getFollowing();
    super.initState();
  }

  Future<void> getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(currentUser.id)
        .collection('timelinePosts')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .get();

    List<Post> _posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      posts = _posts;
      gettingData = false;
    });
  }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    List<String> _followingList = snapshot.docs.map((doc) => doc.id).toList();

    setState(() {
      followingList = _followingList;
      gettingData = false;
    });
  }

  Widget buildTimeline() {
    if (gettingData) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  Widget buildUsersToFollow() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
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
            UserResult userResult = UserResult(user);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
