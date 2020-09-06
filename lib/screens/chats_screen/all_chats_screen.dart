import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/chat_data.dart';
import 'package:whatsapp_clone/providers/chat.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/chats_list_item.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/widgets/body_list.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/stories.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

class AllChatsScreen extends StatefulWidget {
  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen>
    with AutomaticKeepAliveClientMixin {
  DB db = DB();

  Widget _buildChats(List<ChatData> chats) => BodyList(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 10),
          itemCount: chats.length,
          itemBuilder: (ctx, i) => ChatListItem(chatData: chats[i]),
          separatorBuilder: (ctx, i) {
            return Divider(
              indent: 85,
              endIndent: 15,
              height: 0,
              thickness: 1,
              color: kBlackColor3,
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
            color: kBaseWhiteColor,
          ),
        ),
      );

  void updateChats(BuildContext context, AsyncSnapshot<dynamic> snapshots) {
    if (snapshots != null && snapshots.data != null) {
      final currContacts =
          Provider.of<Chat>(context, listen: false).getContacts;
      final currContactLength = currContacts.length;
      final contacts = snapshots.data['contacts'];
      if (contacts != null) if (contacts.length > currContactLength) {
        Provider.of<Chat>(context, listen: false)
            .handleMessagesNotFromContacts(contacts);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chats = Provider.of<Chat>(context).chats;
    final isLoading = Provider.of<Chat>(context).isLoading;
    final uid = Provider.of<Chat>(context).getUserId;    
    return StreamBuilder(
      stream: db.getUserContactsStream(uid),
      builder: (ctx, snapshots) {
        if (!isLoading && snapshots.hasData) updateChats(context, snapshots);
        return Column(
          children: [
            Container(
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
                          color: kBlackColor3,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Stories(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(
              color: kBorderColor3,
              height: 0,
            ),
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : chats.isEmpty ? _buildEmptyIndicator() : _buildChats(chats),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
