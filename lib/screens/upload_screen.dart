import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare_app/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../services/firebase_firestore.dart';
import '../widgets/progress.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with AutomaticKeepAliveClientMixin<UploadScreen> {
  bool gettingLocation = false;
  bool isUploading = false;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String postId = const Uuid().v4();
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  XFile? file = XFile('');

  void handleTakePhoto() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  void handleChooseFromGallery() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) {
      return;
    }
    setState(() {
      this.file = file;
    });
  }

  selectImage(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create Post'),
          children: [
            SimpleDialogOption(
              child: const Text('Photo with Camera'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: const Text('Image from Gallery'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepOrange),
              ),
              child: const Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  void clearImage() {
    setState(() {
      file = XFile('');
    });
  }

  Future<void> compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    img.Image? imageFile = img.decodeImage(await file!.readAsBytes());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(img.encodeJpg(imageFile!, quality: 85));
    file = XFile(compressedImageFile.path);
  }

  Future<String> uploadImage(imageFile) async {
    firebase_storage.UploadTask uploadTask =
        storageRef.ref().child('post_$postId.jpg').putFile(imageFile);
    firebase_storage.TaskSnapshot storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  void createPostInFirestore({
    required String mediaUrl,
    required String location,
    required String description,
  }) {
    postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set({
          'postId': postId,
          'ownerId': widget.currentUser.id,
          'username': widget.currentUser.username,
          'mediaUrl': mediaUrl,
          'description': description,
          'location': location,
          'timestamp': getNow(),
          'likes': {},
        })
        .whenComplete(
          () => {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Your post has been submitted!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            )
          },
        )
        .onError(
          (error, stackTrace) => {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error sumbitting your post: $error'),
                backgroundColor: Theme.of(context).errorColor,
              ),
            )
          },
        );
  }

  Future handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(File(file!.path));
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = XFile('');
      isUploading = false;
      postId = const Uuid().v4();
    });
  }

  Future<bool> getLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // var status = await Permission.location.status;
    // if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
    //   Permission.location.request();
    // }

    _geolocatorPlatform.requestPermission();

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Location services are disabled. Allow and try again.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return false;
    }

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Location permissions are denied. Allow and try again.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return false;
    }
    return true;
  }

  void getUserLocation() async {
    bool permissionEnabled = await getLocationPermissions();

    if (!permissionEnabled) {
      return;
    }

    setState(() {
      gettingLocation = true;
    });

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placemarks =
        await GeocodingPlatform.instance.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark placemark = placemarks[0];
    // String completeAdress =
    //     '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    // print(completeAdress);
    String formattedAddress = '${placemark.locality}, ${placemark.country}';
    locationController.text = formattedAddress;

    setState(() {
      gettingLocation = false;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: const Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Post',
              style: TextStyle(
                color: isUploading || gettingLocation
                    ? Colors.grey
                    : Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            onPressed: isUploading || gettingLocation ? null : handleSubmit,
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : const Text(''),
          SizedBox(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(File(file!.path)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
                enabled: isUploading ? false : true,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
                enabled: isUploading ? false : true,
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: gettingLocation
                ? circularProgress()
                : ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: isUploading
                          ? MaterialStateProperty.all<Color>(Colors.grey)
                          : MaterialStateProperty.all<Color>(Colors.deepOrange),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    label: const Text(
                      'Use Current Location',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                    onPressed: isUploading ? () {} : getUserLocation,
                  ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file!.path != ''
        ? buildUploadForm()
        : buildSplashScreen(
            // context,
            // selectImage(context),
            );
  }
}
