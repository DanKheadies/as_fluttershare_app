// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// Container buildSplashScreen(
//   BuildContext context,
//   Function(BuildContext context) selectImage,
// ) {
//   return Container(
//     color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SvgPicture.asset(
//           'assets/images/upload.svg',
//           height: 260,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(
//             top: 20,
//           ),
//           child: ElevatedButton(
//             style: ButtonStyle(
//               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               backgroundColor:
//                   MaterialStateProperty.all<Color>(Colors.deepOrange),
//             ),
//             child: const Text(
//               'Upload Image',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//               ),
//             ),
//             onPressed: () => selectImage(context),
//           ),
//         ),
//       ],
//     ),
//   );
// }
