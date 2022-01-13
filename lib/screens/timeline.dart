import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/header.dart';
import '../widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  // List<dynamic> users = [];
  // final usersRef = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // getUsers();
    // getUserById();
    // createUser();
    // updateUser();
    // deleteUser();
    super.initState();
  }

  void createUser() {
    usersRef.doc('aklejf932ld90l').set({
      'userName': 'Zoltan',
      'isAdmin': false,
      'postsCount': 0,
    });
  }

  void updateUser() async {
    final doc = await usersRef
        .doc('aklejf932ld90l')
        // .update({
        //   'userName': 'Zlob',
        // });
        .get();
    if (doc.exists) {
      doc.reference.update({
        'userName': 'Zlob',
      });
    }
  }

  void deleteUser() async {
    final doc = await usersRef
        .doc('aklejf932ld90l')
        // .delete();
        .get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  // void getUsers() async {
  //   final QuerySnapshot snapshot = await usersRef
  //       // .where(
  //       //   'isAdmin',
  //       //   isEqualTo: false,
  //       // )
  //       // .where(
  //       //   'postsCount',
  //       //   isGreaterThan: 10,
  //       // )
  //       // .orderBy(
  //       //   'postsCount',
  //       //   descending: true,
  //       // )
  //       // .limit(1)
  //       .get();

  //   setState(() {
  //     users = snapshot.docs;
  //   });
  //   // snapshot.docs.forEach((DocumentSnapshot doc) {
  //   //   print(doc.data());
  //   //   print(doc.id);
  //   //   print(doc.exists);
  //   // });

  //   // usersRef.get().then((QuerySnapshot snapshot) {
  //   //   snapshot.docs.forEach((DocumentSnapshot doc) {
  //   //     print(doc.data());
  //   //     print(doc.id);
  //   //     print(doc.exists);
  //   //   });
  //   // });
  // }

  // void getUserById() async {
  //   const String id = '0OCE6nJfmFu9620ZnaNM';
  //   final DocumentSnapshot doc = await usersRef.doc(id).get();
  //   print(doc.data());
  //   print(doc.id);
  //   print(doc.exists);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: true,
      ),
      // body: FutureBuilder<QuerySnapshot>(
      body: StreamBuilder<QuerySnapshot>(
        // future: usersRef.get(),
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data!.docs
              .map(
                (doc) => Text(
                  doc['userName'],
                ),
              )
              .toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
