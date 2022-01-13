import 'package:flutter/material.dart';

import '../widgets/header.dart';

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: 'Upload',
      ),
      body: const Text('Upload'),
    );
  }
}
