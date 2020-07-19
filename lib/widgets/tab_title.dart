import 'package:flutter/material.dart';

class TabScreenTitle extends StatelessWidget {
  final String title;
  final Widget actionWidget;
  final Function onTap;
  TabScreenTitle({this.title, this.actionWidget, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                if (actionWidget != null) actionWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
