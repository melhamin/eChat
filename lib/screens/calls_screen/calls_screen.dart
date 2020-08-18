import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          height: mq.size.height * 0.12,
          padding: const EdgeInsets.only(left: 15, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calls',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 25,
                      ),
                      decoration: BoxDecoration(
                        color: Hexcolor('#202020'),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 100),
        Center(
          child: Text(
            'You have no calls yet.',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kBaseWhiteColor),
          ),
        ),
        SizedBox(height: 20),       
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
    path.quadraticBezierTo(size.width - 20, 10, size.width - 10, size.height - 10);
    path.lineTo(size.width, size.height - 30);
    path.lineTo(size.width, size.height - 10)    ;
    path.lineTo(size.width - 10, size.height - 5)    ;

    path.lineTo(size.width - 10, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

