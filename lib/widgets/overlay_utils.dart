import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:simple_animations/simple_animations.dart';

import '../consts.dart';
// import 'package:simple_animations/simple_animations.dart';

class OverlayUtils {
  static Timer _toastTimer;
  static OverlayEntry _overlayEntry;

  static void overlay(
      {BuildContext context,
      Widget child,
      Alignment alignment,
      Duration duration,
      Color color}) {
        if(_overlayEntry == null)
    if (_toastTimer == null || !_toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, child, alignment, color);
      Overlay.of(context).insert(_overlayEntry);
    }
  }

  static removeOverlay() {
    if(_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  static hasOverlay() => _overlayEntry != null;
  

  static OverlayEntry createOverlayEntry(
      BuildContext context, Widget child, Alignment alignment, Color color) {
    return OverlayEntry(            
      builder: (context) => Align(
        alignment: alignment,
        child: 
        ToastMessageAnimation(
          Material(
            color: Colors.transparent,
            child: child,
          ),        
        ),
      ),
    );
  }
}

class ToastMessageAnimation extends StatelessWidget {
  final Widget child;
  ToastMessageAnimation(this.child);
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(kBlackColor2);
    final tween = MultiTrackTween([
      Track("translateY")
          .add(
            Duration(milliseconds: 250),
            Tween(begin: -100.0, end: 0),
            curve: Curves.easeOut,
          ),          
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0))          
    ]);

    return ControlledAnimation(
        duration: tween.duration,
        tween: tween,
        child: child,
        builderWithChild: (context, child, animation) => Opacity(
    opacity: animation["opacity"],
    child: Transform.translate(
        offset: Offset(0, animation["translateY"]), child: child),
        ),
      );   
  }
}
