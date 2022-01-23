import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './edit_profile_screen.dart';
import '../services/firebase_firestore.dart';
import '../services/google_signin.dart';
import '../widgets/header.dart';
import '../widgets/post.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_posts.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'ProfileScreen';

  const ProfileScreen({
    Key? key,
    required this.profileId,
    required this.hasBack,
  }) : super(key: key);

  final String profileId;
  final bool hasBack;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFollowing = false;
  bool isLoading = false;
  int followerCount = 0;
  int followingCount = 0;
  int postCount = 0;
  List<Post> posts = [];
  final String currentUserId = currentUser.id;
  String postOrientation = 'grid';

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  void checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  void getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();

    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  void getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();

    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  Future<void> getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentUserId: currentUserId,
        ),
      ),
    ).then((val) => setState(() {}));
  }

  void handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      },
    );

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      },
    );

    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      },
    );
  }

  void handleFollowUser() {
    setState(() {
      isFollowing = true;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'commentData': '',
      'mediaUrl': '',
      'ownerId': widget.profileId,
      'postId': '',
      'timestamp': getNow(),
      'type': 'follow',
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'username': currentUser.username,
    });
  }

  setPostOrientation(String _postOrientation) {
    setState(() {
      postOrientation = _postOrientation;
    });
  }

  Row buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(
            Icons.grid_on,
          ),
          color: postOrientation == 'grid'
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          onPressed: () => setPostOrientation('grid'),
        ),
        IconButton(
          icon: const Icon(
            Icons.list,
          ),
          color: postOrientation == 'list'
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          onPressed: () => setPostOrientation('list'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Profile',
        hasLeading: widget.hasBack,
      ),
      body: RefreshIndicator(
        onRefresh: () => getProfilePosts(),
        child: ListView(
          children: [
            buildProfileHeader(
              context,
              widget.profileId,
              currentUserId,
              isFollowing,
              postCount,
              followerCount,
              followingCount,
              editProfile,
              handleUnfollowUser,
              handleFollowUser,
            ),
            const Divider(),
            buildTogglePostOrientation(),
            const Divider(
              height: 0,
            ),
            buildProfilePosts(
              isLoading,
              posts,
              postOrientation,
              () => getProfilePosts,
            )
          ],
        ),
      ),
    );
  }
}
