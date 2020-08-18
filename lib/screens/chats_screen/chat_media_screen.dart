import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/widgets/back_button.dart';

class ChatMediaScreen extends StatefulWidget {
  final String groupId;
  ChatMediaScreen(this.groupId);
  @override
  _ChatMediaScreenState createState() => _ChatMediaScreenState();
}

class _ChatMediaScreenState extends State<ChatMediaScreen> {
  DB db;

  @override
  void initState() {
    super.initState();
    db = DB();
  }

  @override
  Widget build(BuildContext context) {    
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            leading: CBackButton(),
            centerTitle: true,
            title: Text('Chat Media', style: kAppBarTitleStyle),
          ),
        ),
        body: StreamBuilder(
          stream: db.getChatMediaStream(widget.groupId),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CupertinoActivityIndicator());
            else if (snapshot.data.documents.length == 0)
              return Center(
                  child: Text(
                'No media avaialable.',
                style: kChatItemTitleStyle,
              ));
            else {
              var documents = snapshot.data.documents;
              return GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 15),
                itemCount: documents.length,
                itemBuilder: (ctx, i) => SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.network(
                    documents[i]['url'],
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      return progress != null
                          ? Center(child: CupertinoActivityIndicator())
                          : child;
                    },
                  ),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
