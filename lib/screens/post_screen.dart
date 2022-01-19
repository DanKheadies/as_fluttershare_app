import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './home.dart';
import '../widgets/header.dart';
import '../widgets/post.dart';
import '../widgets/progress.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({
    Key? key,
    required this.userId,
    required this.postId,
  }) : super(key: key);

  final String userId;
  final String postId;

  @override
  Widget build(BuildContext context) {
    print('post screen');
    print(userId);
    print(postId);
    return FutureBuilder<DocumentSnapshot>(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        print('post screen builder');
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data!);
        print(post);
        print(post.description);
        print(post.likes);
        print(post.location);
        print(post.mediaUrl);
        print(post.ownerId);
        print(post.postId);
        print(post.username);
        return Center(
          child: Scaffold(
            appBar: header(
              context,
              titleText: post.description,
            ),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
