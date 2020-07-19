import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/chat_item_screen.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/widgets/body_list.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

class ContactsScreen extends StatelessWidget {
  final DB db = DB();
  String getGroupId(BuildContext context, String contact) {
    String groupId;
    final userId = Provider.of<User>(context, listen: false).getUserId;
    if (userId.hashCode <= contact.hashCode)
      groupId = '$userId-$contact';
    else
      groupId = '$contact-$userId';

    return groupId;
  }

  void onTap(BuildContext context, DocumentSnapshot item) {
    Person person = Person.fromSnapshot(item);

    // Checks if user has already interacted with peer
    // if has interacted pass chats object otherwise pass an empty one
    final initData = Provider.of<User>(context, listen: false).chats.firstWhere(
        (element) {
      return element.person.uid == person.uid;
    },
        orElse: () => new InitChatData(
            groupId: getGroupId(context, item.documentID),
            messages: [],
            person: person));

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatItemScreen(initData),
    ));
  }

  Widget _buildContactsItem(BuildContext context, DocumentSnapshot item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Hexcolor('#121212'),
        onTap: () => onTap(context, item),
        child: Container(
          height: 70,
          child: Center(
            child: ListTile(
                // contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Hexcolor('#303030'),
                  radius: 27,
                  child: (item['imageUrl'] == null || item['imageUrl'] == '')
                      ? Icon(
                          Icons.person,
                          size: 25,
                          color: kBaseWhiteColor,
                        )
                      : null,
                  backgroundImage:
                      (item['imageUrl'] != null && item['imageUrl'] != '')
                          ? CachedNetworkImageProvider(item['imageUrl'])
                          : null,
                ),
                title: Text(item['username'], style: kChatItemTitleStyle)),
          ),
        ),
      ),
    );
  }

  Widget _buildContacts(
          BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) =>
      ListView.separated(
        padding: const EdgeInsets.only(top: 20),
        itemCount: snapshot.data.documents.length,
        itemBuilder: (ctx, i) {
          // print('snapshot: ${snapshot.data.documents[i].documentID}');
          final item = snapshot.data.documents[i];
          return _buildContactsItem(context, item);
        },
        separatorBuilder: (ctx, _) => Divider(
          indent: 85,
          // endIndent: 15,
          height: 0,
          color: kBorderColor1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          height: mq.size.height * 0.12,
          child: TabScreenTitle(
            title: 'Contacts',
            actionWidget: CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {},
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(Icons.more_vert, color: Colors.white, size: 25),
                decoration: BoxDecoration(
                  color: Hexcolor('#202020'),
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
