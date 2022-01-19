import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './home.dart';
import './profile.dart';
import '../models/user.dart';
import '../widgets/progress.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  final String currentUserId;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _bioValid = true;
  bool _displayNameValid = true;
  bool isLoading = false;
  TextEditingController bioController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  late User user;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text('Display Name',
              style: TextStyle(
                color: Colors.grey,
              )),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: 'Update Display Name',
            errorText: _displayNameValid ? '' : 'Display Name too short',
          ),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text('Bio Name',
              style: TextStyle(
                color: Colors.grey,
              )),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update Bio',
            errorText: _bioValid ? '' : 'Bio too long',
          ),
        ),
      ],
    );
  }

  void updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  void logout() async {
    await googleSignIn.signOut();
    Navigator.pop(context);
    // Navigator.pop(context, 0);
    // Navigator.pushReplacementNamed(
    //   context,
    //   Home.id,
    // );
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   Home.id,
    //   (route) => false,
    // );
    // Navigator.of(context).pushReplacementNamed(Home.id);
    // Navigator.pushNamedAndRemoveUntil(
    //   context,
    //   Home.id,
    //   ModalRoute.withName('//'),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            // size: 30,
            color: Colors.black,
          ),
          // onPressed: () => Navigator.pop(context),
          onPressed: () => Navigator.pop(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(
                profileId: widget.currentUserId,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 8,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          buildDisplayNameField(),
                          buildBioField(),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: updateProfileData,
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton.icon(
                        onPressed: logout,
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 20,
                        ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
