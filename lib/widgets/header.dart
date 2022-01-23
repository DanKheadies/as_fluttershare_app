import 'package:flutter/material.dart';

AppBar header(
  BuildContext context, {
  bool isAppTitle = false,
  String titleText = '',
  bool removeBackButton = false,
  bool hasLeading = false,
  String leadingParam = '',
}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'FlutterShare' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50 : 22,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    leading: hasLeading
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context, leadingParam);
            },
          )
        : const SizedBox(),
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.secondary,
  );
}
