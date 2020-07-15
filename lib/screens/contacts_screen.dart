import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/providers/all_users.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/chat_item_screen.dart';

class ContactsScreen extends StatelessWidget {
  List<DocumentSnapshot> getItems(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    List<DocumentSnapshot> result = [];
    final userID = Provider.of<User>(context, listen: false).getUserId;
    snapshot.removeWhere((element) => element.documentID != userID);
  }

  @override
  Widget build(BuildContext context) {
    final contacts = Provider.of<AllUsers>(context).allUsers;
    return Scaffold(
      body:
          // ListView.separated(
          //       padding: const EdgeInsets.only(top: 10),
          //       itemCount: contacts.length,
          //       itemBuilder: (ctx, i) {
          //         // print('snapshot: ${snapshot.data.documents[i].documentID}');
          //         // final item = snapshot.data.documents[i];
          //         return _buildContactsItem(context, contacts[i]);
          //       },
          //       separatorBuilder: (ctx, _) => Divider(
          //         color: Colors.black.withOpacity(0.1),
          //       ),
          //     )
          //   // },
          // );
          StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: Text('loading...'),
            );
          return ListView.separated(
            padding: const EdgeInsets.only(top: 10),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (ctx, i) {
              // print('snapshot: ${snapshot.data.documents[i].documentID}');
              final item = snapshot.data.documents[i];
              return _buildContactsItem(context, item);
            },
            separatorBuilder: (ctx, _) => Divider(
              color: Colors.black.withOpacity(0.1),
            ),
          );
        },
      ),
    );
  }

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
    Person person = Person(
        uid: item.documentID,
        name: item['username'],
        imageUrl: item['imageUrl']);
    final initData =
        Provider.of<User>(context, listen: false).chats.firstWhere((element) {
      return element.person.uid == person.uid;
    }, orElse: () => new InitChatData(groupId: getGroupId(context, item.documentID), messages: [], person: person));

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatItemScreen(initData),
    ));
  }

  Widget _buildContactsItem(BuildContext context, DocumentSnapshot item) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.black.withOpacity(0.12),
      onTap: () => onTap(context, item),
      child: ListTile(
        leading: CircleAvatar(
          radius: 27,
          backgroundImage: CachedNetworkImageProvider(item['imageUrl']),
        ),
        title: Text(item['username']),
      ),
    );
  }
}
