import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/screens/chat_item_screen.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
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
            separatorBuilder: (ctx, _) => Divider(color: Colors.black.withOpacity(0.1),),
          );
        },
      ),
    );
  }

  void onTap(BuildContext context, DocumentSnapshot item) {    
    Person person = Person(uid: item.documentID, name: item['username'], imageUrl: item['imageUrl']);   
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatItemScreen(person),      
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
