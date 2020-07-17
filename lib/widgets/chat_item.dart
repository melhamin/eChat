import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/screens/chat_item_screen.dart';

class ChatItem extends StatefulWidget {
  final InitChatData initChatData;
  bool withDetails = false;

  ChatItem({this.initChatData, this.withDetails});

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  List<Message> unreadMessages = [];
  int unreadCount = 0;

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

  Widget _buildPreviewText(String peerId) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('messages')
          .document(widget.initChatData.groupId)
          .collection(widget.initChatData.groupId)
          .limit(1)
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (ctx, snapshots) {
        if (!snapshots.hasData)
          return Text('loading...');
        else {
          if (snapshots.data.documents.length != 0) {
            final snapshot = snapshots.data.documents[0];
            Message newMsg = Message.fromSnapshot(snapshot);
            final exist = unreadMessages.firstWhere(
                (element) => element.fromId == newMsg.fromId,
                orElse: () => null);

            if (exist != null) unreadMessages.insert(0, newMsg);

            if (newMsg.timeStamp
                .isAfter(widget.initChatData.messages[0].timeStamp))
              // if(wid)
              widget.initChatData.addMessage(newMsg);

            return Row(
              children: [
                newMsg.type == '1'
                    ? Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 15,
                              color: Colors.black.withOpacity(0.45),
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
            return Container();
        }
      },
    );
  }

  Widget _buildWithoutDetails(Person info) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(_buildRoute());
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Hexcolor('#303030'),
            backgroundImage: (info.imageUrl != null && info.imageUrl != '')
                ? CachedNetworkImageProvider(info.imageUrl)
                : null,
            child: (info.imageUrl == null || info.imageUrl == '')
                ? Icon(
                    Icons.person,
                    color: kBaseWhiteColor,
                  )
                : null,
            radius: 27,
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 54,
            child: Text(
              info.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: kBaseWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.initChatData.person;
    final messages = widget.initChatData.messages;
    return widget.withDetails
        ? _buildWithoutDetails(person)
        : Material(
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
                  leading: CircleAvatar(
                    backgroundColor: Hexcolor('#303030'),
                    radius: 27,
                    backgroundImage:
                        (person.imageUrl != null && person.imageUrl != '')
                            ? CachedNetworkImageProvider(person.imageUrl)
                            : null,
                    child: (person.imageUrl == null || person.imageUrl == '')
                        ? Icon(
                            Icons.person,
                            color: kBaseWhiteColor,
                          )
                        : null,
                  ),
                  title: Text(person.name, style: kChatItemTitleStyle),
                  subtitle: _buildPreviewText(person.uid),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (messages.isNotEmpty)
                        Text(getTime(messages[0]),
                            style: kChatItemSubtitleStyle),
                      if (messages.isNotEmpty &&
                          messages[0].fromId == person.uid) ...[
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
                  ),
                ),
              ),
            ),
          );
  }
}
