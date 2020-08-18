import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:whatsapp_clone/screens/contacts_screen/contact_details.dart';
import 'package:whatsapp_clone/widgets/back_button.dart';

class MyAppBar extends StatefulWidget {
  final Person info;
  final String groupId;
  MyAppBar(this.info, this.groupId);
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
    _animationController.removeListener(() { });
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
        builder: (context) => ContactDetails(widget.info, widget.groupId),
      ),
    );
  }

  stream() {
    return Firestore.instance
        .collection(USERS_COLLECTION)
        .document(widget.info.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return AppBar(
      backgroundColor: Hexcolor('#202020'),
      centerTitle: true,
      elevation: 0,
      leading: CBackButton(),
      title: CupertinoButton(
        onPressed: goToContactDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.info.name,
              style: kAppBarTitleStyle,
            ),
            if (collapsed)
              StreamBuilder(
                  stream: stream(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData)
                      return Container(width: 0, height: 0);
                    else {
                      if(snapshot.data == null)
                      print('online --------> null');
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
          child: CupertinoButton(
            onPressed: goToContactDetails,
            padding: const EdgeInsets.all(0),
            child: CircleAvatar(
              backgroundColor: Hexcolor('#303030'),
              radius: 23,
              backgroundImage:
                  (widget.info.imageUrl != null && widget.info.imageUrl != '')
                      ? CachedNetworkImageProvider(widget.info.imageUrl)
                      : null,
              child:
                  (widget.info.imageUrl == null || widget.info.imageUrl == '')
                      ? Icon(
                          Icons.person,
                          color: kBaseWhiteColor,
                        )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
