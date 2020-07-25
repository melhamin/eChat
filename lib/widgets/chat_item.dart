import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/screens/chat_screen.dart';

class ChatItem extends StatefulWidget {
  final InitChatData initChatData;

  ChatItem({
    @required this.initChatData,
  });

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  DB db;
  List<Message> unreadMessages = [];
  int unreadCount = 0;

  @override
  void initState() {
    db = DB();
    super.initState();
  }

  String getDate() {
    DateTime date = DateTime.now();
    return DateFormat.yMd(date).toString();
  }

  Route _buildRoute() {
    return MaterialPageRoute(
      builder: (context) => ChatItemScreen(widget.initChatData),
    );
  }

  String getTime(Message message) {
    int hour = message.timeStamp.hour;
    int min = message.timeStamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }

  void _handleAditionToList(Message newMsg) {
    final exist = unreadMessages.firstWhere(
        (element) => element.fromId == newMsg.fromId,
        orElse: () => null);

    if (exist != null) unreadMessages.insert(0, newMsg);

    if (newMsg.timeStamp.isAfter(widget.initChatData.messages[0].timeStamp))
      // if(wid)
      widget.initChatData.addMessage(newMsg);
  }

  Widget _buildPreviewText(String peerId) {
    return StreamBuilder(
      stream: db.getSnapshotsWithLimit(widget.initChatData.groupId, 1),
      builder: (ctx, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting)
          return CupertinoActivityIndicator();
        else {
          if (snapshots.data.documents.length != 0) {
            final snapshot = snapshots.data.documents[0];            
            Message newMsg = Message.fromSnapshot(snapshot);
            _handleAditionToList(newMsg);
            return Row(
              children: [
                newMsg.type == '1'
                    ? Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 15,
                              color: Colors.white.withOpacity(0.45),
                            ),
                            SizedBox(width: 8),
                            Text('Photo', style: kChatItemSubtitleStyle)
                          ],
                        ),
                      )
                    : Flexible(
                        child: Text(newMsg.content,
                            style: kChatItemSubtitleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                if (newMsg.fromId != peerId) ...[
                  SizedBox(width: 5),
                  Icon(
                    Icons.done_all,
                    size: 19,
                    color: newMsg.isSeen
                        ? Theme.of(context).accentColor
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            );
          } else
            return Container(height: 0, width: 0);
        }
      },
    );
  }


  Widget _buildAvatar(Person person) => CircleAvatar(
        backgroundColor: Hexcolor('#303030'),
        radius: 27,
        backgroundImage: (person.imageUrl != null && person.imageUrl != '')
            ? CachedNetworkImageProvider(person.imageUrl)
            : null,
        child: (person.imageUrl == null || person.imageUrl == '')
            ? Icon(
                Icons.person,
                color: kBaseWhiteColor,
              )
            : null,
      );

  Widget _buildLastMessage(List<Message> messages, Person person) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (messages.isNotEmpty)
            Text(getTime(messages[0]), style: kChatItemSubtitleStyle),
          if (messages.isNotEmpty && messages[0].fromId == person.uid) ...[
            SizedBox(height: 5),
            Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).accentColor,
              ),
              child: Center(
                child: Text(
                  '${unreadMessages.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ]
        ],
      );

  @override
  Widget build(BuildContext context) {
    final person = widget.initChatData.person;
    final messages = widget.initChatData.messages;
    return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Hexcolor('#121212'),
              onTap: () {
                Navigator.of(context).push(_buildRoute());
              },
              child: Container(
                height: 80,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: _buildAvatar(person),
                  title: Text(person.name, style: kChatItemTitleStyle),
                  subtitle: _buildPreviewText(person.uid),
                  trailing: _buildLastMessage(messages, person),
                ),
              ),
            ),
          );
  }
}
