import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
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

  /**
   * Container(          
          height: mq.size.height * 0.25,
          padding: const EdgeInsets.only(left: 15, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(    
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
                    Container(
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
                  ],
                ),
              ),
              Container(
                // color: Colors.yellowAccent,
                height: mq.size.height * 0.15,
                child: ListView.separated(                    
                  scrollDirection: Axis.horizontal,
                  itemCount: chats.length,
                  itemBuilder: (ctx, i) =>
                      ChatItem(initChatData: chats[i], withDetails: true),
                      separatorBuilder: (_,__) => SizedBox(width: 30),
                ),                
              ),
            ],
          ),
        ),
   */

  @override
  Widget build(BuildContext context) {    
    final mq = MediaQuery.of(context);
    return Column(
      children: [
        Container(
          height: mq.size.height * 0.12,
          padding: const EdgeInsets.only(left: 15, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contacts',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 25,
                      ),
                      decoration: BoxDecoration(
                        color: Hexcolor('#202020'),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
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
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder:
                    (BuildContext ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: Text('loading...'),
                    );
                  return ListView.separated(
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
                },
              ),
            ),
          ),
        ),
      ],
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
                radius: 27,
                backgroundImage: CachedNetworkImageProvider(item['imageUrl']),
              ),
              title: Text(item['username'], style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.87)
              ),),
            ),
          ),
        ),
      ),
    );
  }
}
