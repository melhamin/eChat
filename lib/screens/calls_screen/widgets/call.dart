import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
import 'package:whatsapp_clone/widgets/toast_utils.dart';

class Call extends StatefulWidget {
  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> {
  bool endCallPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      decoration: BoxDecoration(
        color: kBlackColor3,
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width,
      ),
      height: !endCallPressed ? size.height * 0.2 : size.height * 0.2 + 45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: size.height * 0.1,
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: Avatar(imageUrl: myPic, radius: 25),
              title: Text(
                'Username',
                style: TextStyle(
                  color: kBaseWhiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Calling...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: CupertinoButton(
                pressedOpacity: 0.6,
                padding: const EdgeInsets.all(0),
                onPressed: () => setState(() => endCallPressed = true),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).errorColor,
                  radius: 25,
                  child: Center(
                    child: Icon(
                      Icons.call_end,
                      color: kBaseWhiteColor,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // SizedBox(height: 15),
          Container(
            height: size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.mic_off, color: kBaseWhiteColor),
                Icon(Icons.speaker_phone, color: kBaseWhiteColor),
                Icon(Icons.add, color: kBaseWhiteColor),
                Icon(Icons.camera_alt, color: kBaseWhiteColor),
                Icon(Icons.people, color: kBaseWhiteColor),
              ],
            ),
          ),
          if (endCallPressed) SizedBox(height: 15),
          if(endCallPressed)
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 0),
              alignment: Alignment.center,
              constraints: BoxConstraints(
                // maxHeight: endCallPressed ? 30 : 0
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color:
                          endCallPressed ? Theme.of(context).accentColor.withOpacity(0.1) : Colors.transparent,
                      width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CupertinoButton(                    
                    padding: const EdgeInsets.all(0),
                    onPressed: () => ToastUtils.removeOverlay(),
                    child: Text(
                      'End Call',
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  VerticalDivider(),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => setState(() => endCallPressed = false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: kBaseWhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:whatsapp_clone/consts.dart';
// import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
// import 'package:whatsapp_clone/widgets/back_button.dart';

// class Call extends StatelessWidget {
//   Widget _buildIcon(IconData icon, {Color backColor, Color iconColor, Function onTap}) {
//     return CupertinoButton(
//       pressedOpacity: 0.6,
//       padding: const EdgeInsets.all(0),
//       onPressed: onTap?? () {},
//           child: CircleAvatar(
//         backgroundColor: backColor ?? kBlackColor1,
//         radius: 40,
//         child: Center(
//           child: Icon(
//             icon,
//             color: iconColor ?? kBaseWhiteColor.withOpacity(0.5),
//             size: 35,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return
//     Scaffold(
//       backgroundColor: kBlackColor,
//       body: Container(
//         padding: EdgeInsets.only(top: size.height * 0.05),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: CBackButton(),
//                 ),
//                 Flexible(
//                   child: Align(
//                     alignment: Alignment.center - Alignment(Alignment.center.x - 20, Alignment.center.y),
//                     child: Text(
//                       'End-to-End Encrypted',
//                       style: TextStyle(color: kBaseWhiteColor.withOpacity(0.6)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: size.height * 0.05),
//             Wrap(
//               direction: Axis.vertical,
//               crossAxisAlignment: WrapCrossAlignment.center,
//               children: [
//                 Text(
//                   'Username',
//                   style: TextStyle(
//                       color: kBaseWhiteColor,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Ringing',
//                   style: TextStyle(
//                       color: kBaseWhiteColor,
//                       fontSize: 17,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(height: 40),
//                 Avatar(imageUrl: myPic, radius: size.width * 0.2),
//               ],
//             ),
//             SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildIcon(Icons.speaker_phone),
//                 SizedBox(width: 15),
//                 _buildIcon(Icons.camera_alt),
//                 SizedBox(width: 15),
//                 _buildIcon(Icons.mic_off),
//               ],
//             ),
//             SizedBox(height: 40),
//             _buildIcon(
//               Icons.call_end,
//               backColor: Theme.of(context).errorColor,
//               iconColor: Colors.white,
//               onTap: () => Navigator.of(context).pop(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
