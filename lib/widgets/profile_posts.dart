import 'package:flutter/material.dart';
import 'package:fluttershare_app/widgets/progress.dart';
import 'package:flutter_svg/svg.dart';

import '../widgets/post.dart';
import '../widgets/post_tile.dart';

Widget buildProfilePosts(
  bool isLoading,
  List<Post> posts,
  String postOrientation,
  Function getProfilePosts,
) {
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
          child: PostTile(
            post: post,
            updateTiles: () => getProfilePosts(),
          ),
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
    for (var post in posts) {
      post.refreshPosts = () {
        getProfilePosts();
      };
    }
    return Column(
      children: posts,
    );
  } else {
    return const Text('Something\'s gone horribly wrong...');
  }
}
