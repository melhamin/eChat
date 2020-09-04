import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
import 'package:whatsapp_clone/widgets/overlay_utils.dart';

class CallingScreen extends StatefulWidget {
  final User reciever;

  const CallingScreen({
    Key key,
    @required this.reciever,
  }) : super(key: key);
  @override
  _CallingScreenState createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  bool endCallPressed = false;
  bool isFullScreen = false;
  

  Widget _buildEndCallIcon({double radius}) {
    return CupertinoButton(
      pressedOpacity: 0.6,
      padding: const EdgeInsets.all(0),
      onPressed: () => OverlayUtils.removeOverlay(),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).errorColor,
        radius: radius ?? 25,
        child: Center(
          child: Icon(
            Icons.call_end,
            color: kBaseWhiteColor,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget _actionIconSmall(IconData icon, {Color color, Function onPressed}) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: onPressed ?? () {},
      child: Icon(icon, color: color ?? kBaseWhiteColor),
    );
  }

  Widget _actionIconLarge(IconData icon, {Color color, Function onPressed}) {
    final size = MediaQuery.of(context).size;
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: onPressed ?? () {},
      child: Container(
        padding: EdgeInsets.all(size.width * 0.07),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kBlackColor3,
          // border: Border.all(color: kBorderColor4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: MediaQuery.of(context).size.height * 0.05,
          color: color ?? kBaseWhiteColor.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildActionIconsSmall() {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width - 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionIconSmall(Icons.mic_off),
          _actionIconSmall(Icons.speaker_phone),
          _actionIconSmall(Icons.add),
          _actionIconSmall(Icons.camera_alt),
          _actionIconSmall(Icons.fullscreen, onPressed: toggleFullScreen)
        ],
      ),
    );
  }

  Widget _buildActionIconsLarge() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionIconLarge(Icons.mic_off),
          _actionIconLarge(Icons.speaker_phone),
          _actionIconLarge(Icons.add),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(kBlackColor2);
    final size = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: isFullScreen
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
      padding: isFullScreen
          ? const EdgeInsets.all(0)
          : const EdgeInsets.only(left: 15, right: 15, top: 10),
      decoration: BoxDecoration(
        color: isFullScreen ? Colors.black.withOpacity(0.9) : kBlackColor3,
        borderRadius: isFullScreen ? null : BorderRadius.circular(20),
      ),
      constraints: BoxConstraints(
        maxHeight: isFullScreen ? size.height : 140,
        maxWidth: size.width,
      ),
      // width: 100,
      child: Stack(
        children: [
          if (!isFullScreen)
            Positioned(
              right: 10,
              top: 10,
              child: _buildEndCallIcon(),
            ),
          if (!isFullScreen)
            Positioned(
              top: 75,
              left: 10,
              child: _buildActionIconsSmall(),
            ),
          if (isFullScreen)
            Positioned(
              top: 30,
              left: 15,
              child: CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: kBaseWhiteColor,
                ),
                onPressed: toggleFullScreen,
              ),
            ),
          if (isFullScreen)
            Positioned(
              top: size.height * 0.45,
              child: _buildActionIconsLarge(),
            ),
          if (isFullScreen)
            Positioned(
              top: size.height * 0.7,
              left: size.width / 2 - size.height * 0.06,
              child: _buildEndCallIcon(radius: size.width * 0.1),
            ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            child: _Name(isFullScreen: isFullScreen, reciever: widget.reciever),
            left: !isFullScreen ? 10 : size.width / 2 - size.width * 0.15,
            top: !isFullScreen ? 10 : size.height * 0.15,
          ),
        ],
      ),
    );
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }
}

class _Name extends StatelessWidget {
  const _Name({
    Key key,
    @required this.isFullScreen,
    this.reciever,
  }) : super(key: key);

  final bool isFullScreen;
  final User reciever;

  Widget _buildName() {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment:
          isFullScreen ? WrapCrossAlignment.center : WrapCrossAlignment.start,
      runAlignment: WrapAlignment.center,
      children: [
        Text(
          reciever.username,
          style: TextStyle(
            color: kBaseWhiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // SizedBox(height: 10),
        Text(
          'Calling...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Wrap(
      crossAxisAlignment:
          isFullScreen ? WrapCrossAlignment.center : WrapCrossAlignment.start,
      direction: isFullScreen ? Axis.vertical : Axis.horizontal,
      children: [
        Avatar(
            imageUrl: reciever.imageUrl,
            radius: isFullScreen ? size.width * 0.15 : 25),
        if (isFullScreen) SizedBox(height: 10),
        if (!isFullScreen) SizedBox(width: 10),
        _buildName()
      ],
    );
  }
}
