import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/activity_feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/upload_screen.dart';

class Auth extends StatelessWidget {
  const Auth({
    Key? key,
    required this.currentUser,
    required this.pageController,
    required this.pageIndex,
    required this.navHandler,
    required this.onPageChanged,
  }) : super(key: key);

  final User currentUser;
  final PageController pageController;
  final int pageIndex;
  final Function(int) navHandler;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          TimelineScreen(currentUser: currentUser),
          const ActivityFeedScreen(),
          UploadScreen(currentUser: currentUser),
          const SearchScreen(),
          ProfileScreen(profileId: currentUser.id, hasBack: false),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: navHandler,
        activeColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.whatshot,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
  }
}
