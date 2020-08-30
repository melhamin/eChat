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
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/providers/chat.dart';
import 'package:whatsapp_clone/screens/chats_screen/chat_item_screen.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/utils/utils.dart';

class ChatListItem extends StatefulWidget {
  final InitChatData initChatData;

  ChatListItem({@required this.initChatData})
      : super(key: GlobalKey<_ChatListItemState>());

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  // GlobalKey key = GlobalKey<_ChatItemState>();
  DB db;
  List<dynamic> unreadMessages = [];
  // int unreadCount;

  @override
  void initState() {
    super.initState();
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
    int hour = message.sendDate.hour;
    int min = message.sendDate.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }  

  void _addNewMessageToList(Message newMsg) { 
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if (widget.initChatData.messages.isEmpty || newMsg.sendDate.isAfter(widget.initChatData.messages[0].sendDate)) {      
      widget.initChatData.addMessage(newMsg);

      if(newMsg.fromId != widget.initChatData.userId) {
      widget.initChatData.unreadCount++;

      // play notification sound
      // if(widget.initChatData.messages.isNotEmpty && widget.initChatData.messages[0].sendDate != newMsg.sendDate)
      // if(isIos)
      //   Utils.playSound('mp3/notificationIphone.mp3');
      // else Utils.playSound('mp3/notificationAndroid.mp3');


      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<Chat>(context, listen: false)
            .bringChatToTop(widget.initChatData.groupId);
        setState(() {});
      });
      }
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
            Message newMsg = Message.fromJson(snapshot.data);
            _addNewMessageToList(newMsg);
            return Row(
              children: [
                newMsg.type == MessageType.Media
                    ? Container(
                        child: Row(
                          children: [
                            Icon(
                              newMsg.mediaType == MediaType.Photo ?                            
                              Icons.photo_camera : Icons.videocam,
                              size: newMsg.mediaType == MediaType.Photo ?    15 : 20,
                              color: Colors.white.withOpacity(0.45),
                            ),
                            SizedBox(width: 8),
                            Text(newMsg.mediaType == MediaType.Photo ? 'Photo' : 'Video', style: kChatItemSubtitleStyle)
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

  Widget _buildAvatar(User person) => CircleAvatar(
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

  Widget _buildUnreadCount(List<dynamic> messages, User person) => Column(
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
        // splashColor: Colors.transparent,
        highlightColor: kBlackColor2,
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
            title: Text(person.username, style: kChatItemTitleStyle),
            subtitle: _buildPreviewText(person.id),
            trailing: _buildUnreadCount(messages, person),
          ),
        ),
      ),
    );
  }
}
