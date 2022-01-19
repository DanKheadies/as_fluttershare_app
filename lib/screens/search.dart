import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare_app/widgets/progress.dart';

import './activity_feed.dart';
import './home.dart';
import './profile.dart';
import '../models/user.dart';
import '../widgets/progress.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  bool hasResults = false;
  late Future<QuerySnapshot> searchResultsFuture;
  TextEditingController searchController = TextEditingController();

  void handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .where("displayName", isLessThan: query + '\uf7ff')
        //     .where("displayName", isNotEqualTo: query)
        //     .orderBy("displayName")
        //     .startAt([
        //   query,
        // ]).endAt([
        //   query + '\uf8ff',
        // ])
        .get();

    if (query == '') {
      setState(() {
        hasResults = false;
      });
    } else {
      setState(() {
        searchResultsFuture = users;
        hasResults = true;
      });
    }
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      hasResults = false;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: const Icon(
            Icons.account_box,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Widget buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SvgPicture.asset(
            'assets/images/search.svg',
            height: orientation == Orientation.portrait ? 300 : 200,
          ),
          const Text(
            'Find Users',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 60,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        // snapshot.data?.docs.forEach((doc) {
        //   User user = User.fromDocument(doc);
        //   searchResults.add(Text(user.username));
        // });
        for (var doc in snapshot.data!.docs) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        }
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchField(),
      body: !hasResults ? buildNoContent() : buildSearchResults(),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
    );
  }
}

class UserResult extends StatefulWidget {
  late User user;

  UserResult(this.user);

  @override
  State<UserResult> createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  Future<void> showProfile(BuildContext context,
      {required String profileId}) async {
    final derp = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          profileId: profileId,
        ),
      ),
    ).then((val) => {
          print(val),
          setState(() {}),
        });
    print('search derp');
    print(derp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(
              context,
              profileId: widget.user.id,
            ),
            // onTap: () => ActivityFeedItem(
            //   commentData: '',
            //   mediaUrl: '',
            //   postId: '',
            //   timestamp: Timestamp.now(),
            //   type: '',
            //   userId: user.id,
            //   userProfileImg: '',
            //   username: '',
            // ).showProfile(
            //   context,
            //   profileId: user.id,
            // ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage:
                    CachedNetworkImageProvider(widget.user.photoUrl),
              ),
              title: Text(
                widget.user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.user.username,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Divider(
            height: 2,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
