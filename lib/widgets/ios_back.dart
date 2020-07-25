import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Icon(CupertinoIcons.back, color: Theme.of(context).accentColor),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
