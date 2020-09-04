import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/chat_data.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/providers/chat.dart';
import 'package:whatsapp_clone/screens/chats_screen/chat_item_screen.dart';
import 'package:whatsapp_clone/screens/contacts_screen/widget/contact_item.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/widgets/body_list.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

class ContactsScreen extends StatelessWidget {
  final DB db = DB();
  String getGroupId(BuildContext context, String contact) {
    String groupId;
    final userId = Provider.of<Chat>(context, listen: false).getUserId;
    if (userId.hashCode <= contact.hashCode)
      groupId = '$userId-$contact';
    else
      groupId = '$contact-$userId';

    return groupId;
  }

  void onTap(BuildContext context, DocumentSnapshot item) {
    User person = User.fromJson(item.data);
    final userId = Provider.of<Chat>(context, listen: false).getUserId;
    // Checks if user has already interacted with peer
    // if has interacted pass chats object otherwise pass an empty one
    final initData =
        Provider.of<Chat>(context, listen: false).chats.firstWhere((element) {
      return element.peer.id == person.id;
    }, orElse: () {      
      return new ChatData(
        groupId: getGroupId(context, item.documentID),
        userId: userId,
        peerId: person.id,
        messages: [],
        peer: person,
      );
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatItemScreen(initData),
    ));
  }  

  Widget _buildContacts(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    final userId = Provider.of<Chat>(context, listen: false).getUserId;
    return ListView.separated(
      // padding: const EdgeInsets.only(top: 20),
      itemCount: snapshot.data.documents.length,
      itemBuilder: (ctx, i) {
        final item = snapshot.data.documents[i];
        return item.documentID == userId
            ? Container(height: 0, width: 0)
            : ContactItem(item: item, onTap: onTap);
      },
      separatorBuilder: (ctx, _) => Divider(
        indent: 85,        
        height: 0,
        thickness: 1,
        color: kBlackColor3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          // height: mq.size.height * 0.1,
          child: TabScreenTitle(
            title: 'Contacts',
            actionWidget: CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {},
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(Icons.more_vert, color: Colors.white, size: 25),
                decoration: BoxDecoration(
                  color: kBlackColor3,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        BodyList(
          child: StreamBuilder(
            stream: db.getContactsStream(),
            builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: Text('loading...'),
                );
              return _buildContacts(context, snapshot);
            },
          ),
        ),
      ],
    );
  }
}