import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firebase_firestore.dart';
import '../services/google_signin.dart';
import '../widgets/comment.dart';
import '../widgets/progress.dart';
import '../widgets/header.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({
    Key? key,
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  }) : super(key: key);

  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
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
      'timestamp': getNow(),
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
        'timestamp': getNow(),
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
        hasLeading: true,
        leadingParam: 'comment',
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
