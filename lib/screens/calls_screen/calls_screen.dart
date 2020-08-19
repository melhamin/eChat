import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/calls_screen/widgets/call_item.dart';
import 'package:whatsapp_clone/widgets/body_list.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabScreenTitle(
          title: 'Calls',
          actionWidget: CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Icon(Icons.more_vert, color: Colors.white, size: 25),
              decoration: BoxDecoration(
                color: Hexcolor('#202020'),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          onTap: () {},
        ),
        SizedBox(height: 20),
        BodyList(
          child: ListView.separated(
            itemCount: 10,
            itemBuilder: (_, i) => CallItem(),

            separatorBuilder: (_, i) => Divider(
              indent: 72,
              endIndent: 15,
              height: 0,
              color: kBorderColor1,
            ),
          ),
        )
        // SizedBox(height: 100),
        // Center(
        //   child: Text(
        //     'You have no calls yet.',
        //     style: TextStyle(
        //         fontSize: 20,
        //         fontWeight: FontWeight.bold,
        //         color: kBaseWhiteColor),
        //   ),
        // ),
        // SizedBox(height: 20),
      ],
    );
  }
}

class ChatBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width - 10, 10, size.width - 10, 20);
    path.quadraticBezierTo(
        size.width - 20, 10, size.width - 10, size.height - 10);
    path.lineTo(size.width, size.height - 30);
    path.lineTo(size.width, size.height - 10);
    path.lineTo(size.width - 10, size.height - 5);

    path.lineTo(size.width - 10, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
