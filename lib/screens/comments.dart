import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import './home.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart';

class Comments extends StatefulWidget {
  const Comments({
    Key? key,
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  }) : super(key: key);

  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  String postId = '';
  String postOwnerId = '';
  String postMediaUrl = '';
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    setState(() {
      postId = widget.postId;
      postOwnerId = widget.postOwnerId;
      postMediaUrl = widget.postMediaUrl;
    });
    super.initState();
  }

  Widget buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy(
            'timestamp',
            descending: false,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        for (var comment in snapshot.data!.docs) {
          comments.add(Comment.fromDocument(comment));
        }
        return ListView(
          children: comments,
        );
      },
    );
  }

  void addComment() {
    commentsRef.doc(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        'commentData': commentController.text,
        'mediaUrl': postMediaUrl,
        'ownerId': postOwnerId,
        'postId': postId,
        'timestamp': timestamp,
        'type': 'comment',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Comments',
      ),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Write a comment...',
              ),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              child: const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({
    Key? key,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  }) : super(key: key);

  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(
            timeago.format(
              timestamp.toDate(),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
