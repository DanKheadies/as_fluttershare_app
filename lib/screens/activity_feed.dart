import 'package:flutter/material.dart';

import '../widgets/header.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({Key? key}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Activity Feed',
      ),
      body: const Text('Activity Feed'),
    );
  }
}
