import 'package:flutter/material.dart';

Padding buildButton(
  BuildContext context,
  String text,
  bool isFollowing,
  Function() function,
) {
  function;
  return Padding(
    padding: const EdgeInsets.only(top: 2),
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: isFollowing
            ? MaterialStateProperty.all<Color>(Colors.orange)
            : MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary),
      ),
      onPressed: function,
      child: Container(
        child: Text(
          text,
          style: TextStyle(
            color: isFollowing ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        alignment: Alignment.center,
      ),
    ),
  );
}
