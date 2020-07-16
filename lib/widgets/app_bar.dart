import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/screens/contact_details.dart';

class MyAppBar extends StatefulWidget {
  final Person info;
  MyAppBar(this.info);
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Timer _timer;
  bool collapsed = false;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 3),
    // );
    _timer = Timer(Duration(seconds: 3), () {
      collapse();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void collapse() {
    if (mounted) setState(() => collapsed = true);
  }

  void goToContactDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactDetails(widget.info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Hexcolor('#121212'),
      centerTitle: true,
      elevation: 0,
      leading: BackButton(
        color: Theme.of(context).accentColor,
      ),
      title: GestureDetector(
        onTap: goToContactDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.info.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.87),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: collapsed ? 0 : 18,
              child: Text(
                'tap for more info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 5, bottom: 5),
          child: GestureDetector(
            onTap: goToContactDetails,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              radius: 23,
              backgroundImage: widget.info.imageUrl != null
                  ? CachedNetworkImageProvider(widget.info.imageUrl)
                  : null,
              child: widget.info.imageUrl == null ? Icon(Icons.person) : null,
            ),
          ),
        ),
      ],
    );
  }
}
