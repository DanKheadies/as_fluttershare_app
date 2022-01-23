import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/firebase_firestore.dart';
import '../services/google_signin.dart';
import '../widgets/header.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';
import '../widgets/users_to_follow.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
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
      return buildUsersToFollow(followingList, toggleData);
    } else {
      for (var post in posts) {
        post.refreshPosts = () {
          toggleData();
        };
      }
      return ListView(
        children: posts,
      );
    }
  }

  Future<void> toggleData() async {
    getTimeline();
    getFollowing();
    getTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => toggleData(),
        child: buildTimeline(),
      ),
    );
  }
}
