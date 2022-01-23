import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './progress.dart';
import '../models/user.dart';
import '../screens/comments_screen.dart';
import '../screens/profile_screen.dart';
import '../services/firebase_firestore.dart';
import '../services/google_signin.dart';
import '../widgets/custom_image.dart';

//ignore: must_be_immutable
class Post extends StatefulWidget {
  Post({
    Key? key,
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.likes,
    required this.isPostScreen,
    required this.refreshPosts,
  }) : super(key: key);

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  late bool isPostScreen;
  late Function refreshPosts;

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      isPostScreen: false,
      refreshPosts: () {},
    );
  }

  int getLikeCount(Map likes) {
    if (likes.isEmpty) {
      return 0;
    }
    int count = 0;
    for (var like in likes.values) {
      if (like) {
        count += 1;
      }
    }
    return count;
  }

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isDeleting = false;
  bool isLiked = false;
  bool isPostScreen = false;
  bool showHeart = false;
  int commentCount = 0;
  int likeCount = 0;
  Map likes = {};
  String currentUserId = '';
  String description = '';
  String location = '';
  String mediaUrl = '';
  String ownerId = '';
  String postId = '';
  String username = '';

  @override
  void initState() {
    setState(() {
      currentUserId = currentUser.id;
      postId = widget.postId;
      ownerId = widget.ownerId;
      username = widget.username;
      location = widget.location;
      description = widget.description;
      mediaUrl = widget.mediaUrl;
      likes = widget.likes;
      likeCount = widget.getLikeCount(likes);
      isLiked =
          likes[currentUser.id] != null && likes[currentUser.id] ? true : false;
      isPostScreen = widget.isPostScreen;
    });
    getCommentCount();
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
    );
  }

  FutureBuilder buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(
              context,
              profileId: user.id,
            ),
            child: Text(
              user.username,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }

  Future handleDeletePost(BuildContext parentContext) async {
    return isDeleting
        ? circularProgress()
        : showDialog(
            context: parentContext,
            builder: (context) {
              return AlertDialog(
                title: const Text('Remove this post?'),
                actions: [
                  TextButton(
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onPressed: deletePost,
                  ),
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    // onPressed: () => widget.refreshPosts(),
                  ),
                ],
              );
            },
          );
  }

  void deletePost() async {
    setState(() {
      isDeleting = true;
    });

    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    storageRef.ref().child('post_$postId.jpg').delete();

    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .where(
          'postId',
          isEqualTo: postId,
        )
        .get();

    for (var doc in activityFeedSnapshot.docs) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }

    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection('comments').get();

    for (var doc in commentsSnapshot.docs) {
      if (doc.exists) {
        doc.reference.delete();
      }
    }

    setState(() {
      isDeleting = false;
    });

    print('deleting');
    if (isPostScreen) {
      print('is post screen');
      Navigator.pop(context);
    }
    Navigator.pop(context, 'delete');
    print('did pop');
    widget.refreshPosts();
  }

  void handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(
          const Duration(
            milliseconds: 500,
          ), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  void addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    // if (isNotPostOwner) {
    print('like');
    activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
      'commentData': '',
      'mediaUrl': mediaUrl,
      'ownerId': ownerId,
      'postId': postId,
      'timestamp': getNow(),
      'type': 'like',
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'username': currentUser.username,
    });
    // }
  }

  void removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    // if (isNotPostOwner) {
    activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // }
  }

  Future<void> getCommentCount() async {
    QuerySnapshot snapshot =
        await commentsRef.doc(widget.postId).collection('comments').get();

    setState(() {
      commentCount = snapshot.docs.length;
    });
  }

  GestureDetector buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(
                    begin: 0.8,
                    end: 1.4,
                  ),
                  curve: Curves.decelerate,
                  cycles: 1,
                  builder: (context, anim, _widget) => Transform.scale(
                    scale: anim.value,
                    child: const Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.red,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Column buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 40,
                left: 20,
              ),
            ),
            GestureDetector(
              onDoubleTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                right: 20,
              ),
            ),
            TextButton.icon(
              icon: Icon(
                Icons.chat,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                '$commentCount',
              ),
              onPressed: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 20,
              ),
              child: Text(
                '$likeCount likes',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 20,
              ),
              child: Text(
                username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(' $description'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

void showComments(
  BuildContext context, {
  required String postId,
  required String ownerId,
  required String mediaUrl,
}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return CommentsScreen(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
