import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
// import 'package:simple_animations/simple_animations.dart';

class ToastUtils {
  static Timer _toastTimer;
  static OverlayEntry _overlayEntry;

  static void myToastMessage(
      {BuildContext context,
      Widget child,
      Alignment alignment,
      Duration duration,
      Color color}) {
        if(_overlayEntry == null)
    if (_toastTimer == null || !_toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, child, alignment, color);
      Overlay.of(context).insert(_overlayEntry);
      // _toastTimer = Timer(duration, () {
      //   if (_overlayEntry != null) {          
      //     _overlayEntry.remove();
      //   }
      // });
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
      maintainState: true,      
      builder: (context) => Align(
        alignment: alignment,
        child: 
        ToastMessageAnimation(
          Material(
            color: Colors.transparent,
            child: child,
          ),
          // Material(
          //   color: color,
          //   // elevation: 10,
          //   // shadowColor: Colors.white12,
          //   borderRadius: BorderRadius.circular(10),
          //   child: Container(
          //     padding: const EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //       color: color,
          //     ),
          //     width: 150,
          //     height: 150,
          //     child: Center(
          //       child: child,
          //     ),
          //   ),
          // ),
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
    final tween = MultiTrackTween([
      Track("translateY")
          .add(
            Duration(milliseconds: 250),
            Tween(begin: -100.0, end: 40.0),
            curve: Curves.easeOut,
          ),
          // .add(Duration(seconds: 1, milliseconds: 250),
          //     Tween(begin: 0.0, end: 0.0)),
          // .add(Duration(milliseconds: 250), Tween(begin: 0.0, end: -100.0),
          //     curve: Curves.easeIn),
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0))
          // .add(Duration(seconds: 1), Tween(begin: 1.0, end: 1.0))
          // .add(Duration(milliseconds: 500), Tween(begin: 1.0, end: 0.0)),
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
    // final _tween = MultiTween<Track>()..add(Track.Opacity, );
    // return PlayAnimation(
    //   tween: _tween,
    //   duration: _tween.duration,
    //   builder: (context, child, value) {
    //     return Opacity(
    //       opacity: value['opacity'],
    //       child: Transform.translate(
    //         offset: Offset(0, value['translateY']),
    //         child: child,
    //       ),
    //     );
    //   },
    // );
  }
}
