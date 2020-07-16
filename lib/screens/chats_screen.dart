import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/all_users.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/chat_item_screen.dart';
import 'package:whatsapp_clone/widgets/chat_item.dart';

class ChatsScreen extends StatelessWidget {
  @override
  PageController _pageController = PageController(keepPage: true);

  List<DocumentSnapshot> getItems(
      BuildContext context, List<DocumentSnapshot> snapshots) {
    final userContacts = Provider.of<User>(context).getContacts;
    List<DocumentSnapshot> result = [];

    snapshots.forEach((element) {
      if (userContacts.contains(element.documentID)) result.add(element);
    });

    return result;
  }

  Widget _buildContactsItem(
      BuildContext context, Person person, InitChatData chatData) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatItemScreen(chatData),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.black,
          width: 2,
        ))),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              child: (person.imageUrl == null || person.imageUrl == '')
                  ? Icon(
                      Icons.person,
                      size: 25,
                      color: kBaseWhiteColor,
                    )
                  : null,
              backgroundImage: person.imageUrl == null
                  ? null
                  : CachedNetworkImageProvider(person.imageUrl),
            ),
            SizedBox(height: 8),
            Text(person.name),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(InitChatData initChatData) {
    return ChatItem(initChatData: initChatData);
  }

  Widget _buildTabContent(InitChatData i) {
    return PageView(
      controller: _pageController,
      children: [
        ChatItemScreen(i),
      ],
    );
  }

  Stream<QuerySnapshot> stream() {
    return Firestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final chats = Provider.of<User>(context).chats;
    final mq = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          height: mq.size.height * 0.25,
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {},
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                        decoration: BoxDecoration(
                          color: Hexcolor('#202020'),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // color: Colors.yellowAccent,
                height: mq.size.height * 0.15,
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 15),
                  scrollDirection: Axis.horizontal,
                  itemCount: chats.length,
                  itemBuilder: (ctx, i) =>
                      ChatItem(initChatData: chats[i], withDetails: true),
                  separatorBuilder: (_, __) => SizedBox(width: 30),
                ),
              ),
            ],
          ),
        ),
        chats.isEmpty
            ? Center(
                child: Text(
                  'You have no messages yet.',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kBaseWhiteColor),
                ),
              )
            : Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Hexcolor('#202020'),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
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
                  ),
                ),
              ),
      ],
    );
    // return ListView.separated(
    //   itemCount: items.length,
    //   itemBuilder: (ctx, i) {
    //     return _buildListItem(items[i]);
    //   },
    //   separatorBuilder: (ctx, i) {
    //     return Divider(
    //       indent: 85,
    //       endIndent: 15,
    //       color: Colors.black.withOpacity(0.12),
    //     );
    //   },
    // );
    return Container();
  }
}
