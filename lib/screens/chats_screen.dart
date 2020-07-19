import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/widgets/body_list.dart';
import 'package:whatsapp_clone/widgets/chat_item.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

class ChatsScreen extends StatelessWidget {
  /// Builds chat items located at top of the screen
  Widget _buildWithoutDetails(List<InitChatData> chats) => ListView.separated(
        padding: const EdgeInsets.only(left: 15),
        scrollDirection: Axis.horizontal,
        itemCount: chats.length,
        itemBuilder: (ctx, i) =>
            ChatItem(initChatData: chats[i], withDetails: true),
        separatorBuilder: (_, __) => SizedBox(width: 30),
      );

  Widget _buildWithDetails(List<InitChatData> chats) => BodyList(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 10),
          itemCount: chats.length,
          itemBuilder: (ctx, i) =>
              ChatItem(initChatData: chats[i], withDetails: false),
          separatorBuilder: (ctx, i) {
            return Divider(
              indent: 85,
              endIndent: 15,
              height: 0,
              color: kBorderColor1,
            );
          },
        ),
      );

  Widget _buildEmptyIndicator() => Center(
        child: Text(
          'You have no messages yet.',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kBaseWhiteColor),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final chats = Provider.of<User>(context).chats;
    final mq = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          height: mq.size.height * 0.25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabScreenTitle(
                title: 'Chats',
                actionWidget: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {},
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.add, color: Colors.white, size: 25),
                    decoration: BoxDecoration(
                      color: Hexcolor('#202020'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Container(
                // color: Colors.yellowAccent,
                height: mq.size.height * 0.15,
                child: _buildWithoutDetails(chats),
              ),
            ],
          ),
        ),
        chats.isEmpty ? _buildEmptyIndicator() : _buildWithDetails(chats),
      ],
    );
  }
}
