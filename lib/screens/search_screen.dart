import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare_app/widgets/progress.dart';

import '../models/user.dart';
import '../services/firebase_firestore.dart';
import '../widgets/progress.dart';
import '../widgets/user_result.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
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
        for (var doc in snapshot.data!.docs) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user, () {});
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
