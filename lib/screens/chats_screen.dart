import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/widgets/chat_item.dart';

class ChatsScreen extends StatelessWidget {
  List<DocumentSnapshot> getItems(
      BuildContext context, List<DocumentSnapshot> snapshots) {
    final userContacts = Provider.of<User>(context).getContacts;
    print('user contacts =======>> $userContacts');
    List<DocumentSnapshot> result = [];

    snapshots.forEach((element) {
      if (userContacts.contains(element.documentID)) result.add(element);
    });

    return result;
  }

  Widget _buildListItem(DocumentSnapshot snapshot) {
    Person person = Person.fromSnapshot(snapshot);
    return ChatItem(person);
  }

  Stream<QuerySnapshot> stream() {
    return Firestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: Text('Loading...'),
          );
        else {
          final items = getItems(context, snapshot.data.documents);
          return ListView.separated(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              return _buildListItem(items[i]);
            },
            separatorBuilder: (ctx, i) {
              return Divider(
                indent: 85,
                endIndent: 15,
                color: Colors.black.withOpacity(0.12),
              );
            },
          );
        }
      },
    );
  }
}
