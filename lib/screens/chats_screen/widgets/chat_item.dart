import 'package:audioplayers/audio_cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/init_chat_data.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/chats_screen/chat_item_screen.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/utils/utils.dart';

class ChatItem extends StatefulWidget {
  final InitChatData initChatData;

  ChatItem({@required this.initChatData})
      : super(key: GlobalKey<_ChatItemState>());

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  // GlobalKey key = GlobalKey<_ChatItemState>();
  DB db;
  List<dynamic> unreadMessages = [];
  // int unreadCount;

  @override
  void initState() {
    super.initState();
    // unreadCount = widget.initChatData.unreadCount;
    final userId = widget.initChatData.userId;
    // get number of initially unread messages
    // int index = 0;
    // if (widget.initChatData.messages.isNotEmpty &&
    //     widget.initChatData.messages[0].fromId != userId)
    //   index = widget.initChatData.messages.indexWhere((element) {
    //     print('********* searched element ******* ----> ${element.content}');
    //     return element.isSeen;
    //   });
    // print('index =======> $index');
    // if (index > 0)
    // {
    //   unreadCount = index;
    // print('init Called --- unread ocunt ====> $unreadCount');
    // }
    db = DB();
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

  String formatTime(Message message) {
    int hour = message.timeStamp.hour;
    int min = message.timeStamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }  

  void _addNewMessageToList(Message newMsg) { 
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if (newMsg.timeStamp.isAfter(widget.initChatData.messages[0].timeStamp)) {
      widget.initChatData.addMessage(newMsg);
      widget.initChatData.unreadCount++;

      // play notification sound
      if(isIos)
        Utils.playSound('mp3/notificationIphone.mp3');
      else Utils.playSound('mp3/notificationAndroid.mp3');


      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<User>(context, listen: false)
            .bringChatToTop(widget.initChatData.groupId);
        setState(() {});
      });
    }
  }

  Widget _buildPreviewText(String peerId) {
    return StreamBuilder(
      stream: db.getSnapshotsWithLimit(widget.initChatData.groupId, 1),
      builder: (ctx, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting)
          return Container(height: 0, width: 0);
        else {
          if (snapshots.data.documents.isNotEmpty) {
            final snapshot = snapshots.data.documents[0];
            Message newMsg = Message.fromJson(snapshot);
            _addNewMessageToList(newMsg);
            return Row(
              children: [
                newMsg.type == MessageType.Media
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
        backgroundColor: kBlackColor3,
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

  Widget _buildUnreadCount(List<dynamic> messages, Person person) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (messages.isNotEmpty)
            Text(formatTime(messages[0]), style: kChatItemSubtitleStyle),
          if (widget.initChatData.unreadCount != null && widget.initChatData.unreadCount > 0) ...[
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
                  '${widget.initChatData.unreadCount}',
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
    // print('unread count ===========> $unreadCount');
    return Material(
      key: UniqueKey(),
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: kBlackColor,
        onTap: () {
          // unreadCount = 0;
          widget.initChatData.unreadCount = 0;
          Navigator.of(context).push(_buildRoute());
        },
        child: Container(
          height: 80,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: _buildAvatar(person),
            title: Text(person.name, style: kChatItemTitleStyle),
            subtitle: _buildPreviewText(person.uid),
            trailing: _buildUnreadCount(messages, person),
          ),
        ),
      ),
    );
  }
}
