import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/screens/calls_screen/widgets/call.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
import 'package:whatsapp_clone/screens/contacts_screen/contact_details.dart';
import 'package:whatsapp_clone/widgets/back_button.dart';
import 'package:whatsapp_clone/widgets/overlay_utils.dart';

class MyAppBar extends StatefulWidget {
  final User peer;
  final String groupId;
  MyAppBar(this.peer, this.groupId);
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation _animation;

  Timer _timer;
  bool collapsed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);

    _timer = Timer(Duration(seconds: 3), () {
      collapse();
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(() {});
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void collapse() {
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (this.mounted) setState(() => collapsed = true);
    });
  }

  void goToContactDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactDetails(widget.peer, widget.groupId),
      ),
    );
  }

  stream() {
    return Firestore.instance
        .collection(USERS_COLLECTION)
        .document(widget.peer.id)
        .snapshots();
  }

  bool tapped = false;
  void toggle() {
    setState(() {
      tapped = !tapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kBlackColor2,
      centerTitle: true,
      elevation: 0,
      leading: CBackButton(),
      title: CupertinoButton(
        onPressed: goToContactDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.peer.username, style: kAppBarTitleStyle),
            if (collapsed)
              StreamBuilder(
                  stream: stream(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData)
                      return Container(width: 0, height: 0);
                    else {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: snapshot.data['isOnline'] ? 15 : 0,
                        child: Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      );
                      // return Container();
                    }
                  }),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              height: collapsed ? 0 : 18,
              child: FadeTransition(
                opacity: _animation,
                child: Text(
                  'tap for more info',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 5, bottom: 5),
          child: Wrap(
            children: [
              CupertinoButton(
                onPressed: makeVoiceCall,
                padding: const EdgeInsets.all(0),
                child: Icon(Icons.call, color: Theme.of(context).accentColor),
                // Avatar(imageUrl: widget.peer.imageUrl, radius: 23, color: kBlackColor3),
              ),
              CupertinoButton(
                onPressed: makeVideoCall,
                padding: const EdgeInsets.all(0),
                child: Icon(Icons.video_call,
                    color: Theme.of(context).accentColor),
                // Avatar(imageUrl: widget.peer.imageUrl, radius: 23, color: kBlackColor3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeVoiceCall() {
    OverlayUtils.overlay(
      context: context,
      alignment: Alignment.topCenter,
      child: CallingScreen(),
      duration: Duration(seconds: 5),
    );
  }
  
  void makeVideoCall() {
    OverlayUtils.overlay(
      context: context,
      alignment: Alignment.topCenter,
      child: CallingScreen(),
      duration: Duration(seconds: 5),
    );
  }
}
