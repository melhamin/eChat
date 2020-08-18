import 'package:flutter/material.dart';

class SeenStatus extends StatelessWidget {
  final bool isMe;
  final bool isSeen;
  final DateTime timestamp;
  const SeenStatus({
    this.isSeen,
    this.isMe,
    this.timestamp,
    Key key,
  }) : super(key: key);

  String getTime() {
    int hour = timestamp.hour;
    int min = timestamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();

    return '$hRes:$mRes';
  }

  Widget _buildStatus(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            getTime(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        if (isMe)
          Icon(
            Icons.done_all,
            color: isSeen
                ? Theme.of(context).accentColor
                : Colors.white.withOpacity(0.35),
            size: 19,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _buildStatus(context),
    );
  }
}
