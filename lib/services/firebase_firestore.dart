import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final firebase_storage.FirebaseStorage storageRef =
    firebase_storage.FirebaseStorage.instance;
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final postsRef = FirebaseFirestore.instance.collection('posts');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final usersRef = FirebaseFirestore.instance.collection('users');

Timestamp getNow() {
  return Timestamp.now();
}
