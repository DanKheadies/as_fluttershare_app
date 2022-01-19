import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare_app/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';

import './edit_profile.dart';
import './home.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import '../widgets/post.dart';
import '../widgets/post_tile.dart';

class Profile extends StatefulWidget {
  static const String id = 'profile';

  const Profile({
    Key? key,
    required this.profileId,
  }) : super(key: key);

  final String profileId;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
    print('profile init');
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

  void getProfilePosts() async {
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

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentUserId: currentUserId,
        ),
      ),
    ).then((val) => setState(() {}));
  }

  Padding buildButton(
    String text,
    Function() function,
  ) {
    function;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: isFollowing
              ? MaterialStateProperty.all<Color>(Colors.orange)
              : MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary),
        ),
        onPressed: function,
        child: Container(
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        'Edit Profile',
        editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        'Unfollow',
        handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        'Follow',
        handleFollowUser,
      );
    } else {
      return const SizedBox();
    }
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
      'timestamp': timestamp,
      'type': 'follow',
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'username': currentUser.username,
    });
  }

  FutureBuilder buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
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
                            buildProfileButton(),
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

  Widget buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 260,
          ),
          const Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Text(
              'No Posts',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      for (var post in posts) {
        gridTiles.add(
          GridTile(
            child: PostTile(post: post),
          ),
        );
      }
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    } else {
      return const Text('Something\'s gone horribly wrong...');
    }
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
      ),
      body: ListView(
        children: [
          buildProfileHeader(),
          const Divider(),
          buildTogglePostOrientation(),
          const Divider(
            height: 0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
