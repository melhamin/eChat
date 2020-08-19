import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/init_chat_data.dart';
import 'package:whatsapp_clone/models/person.dart';

class StoryItem extends StatefulWidget {
  final InitChatData chatData;
  StoryItem(this.chatData);
  @override
  _StoryItemState createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  Widget _buildItem(Person info) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {},
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border:
                  Border.all(color: Theme.of(context).accentColor, width: 1.5),
            ),
            child: CircleAvatar(
              backgroundColor: kBlackColor3,
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
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 54,
          child: Center(
            child: Text(
              info.name.split(' ')[0],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: kBaseWhiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildItem(widget.chatData.person);
  }
}
