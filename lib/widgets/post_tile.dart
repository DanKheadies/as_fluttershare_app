import 'package:flutter/material.dart';

import './custom_image.dart';
import './post.dart';
import '../screens/post_screen.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    Key? key,
    required this.post,
    required this.updateTiles,
  }) : super(key: key);

  final Post post;
  final Function updateTiles;

  void showPost(context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
    if (result == 'delete') {
      updateTiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
