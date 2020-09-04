import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class CBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return isIos ?
    CupertinoButton(      
      padding: const EdgeInsets.all(0),
        child: Icon(CupertinoIcons.back, color: Theme.of(context).accentColor),
        onPressed: () => Navigator.of(context).pop(),
      ) : BackButton(color: Theme.of(context).accentColor, );
  }
}