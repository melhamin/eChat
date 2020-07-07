import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';

class ChatItemScreen extends StatefulWidget {
  final Person person;
  ChatItemScreen(this.person);

  @override
  _ChatItemScreenState createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> {
  TextEditingController _textEditingController;
  ScrollController _scrollController;
  FocusNode _textFieldFocusNode;

  bool _initLoaded = true;
  bool _isLoading = true;

  String userId;
  String peerId;
  String groupChatId;
  var messages;

  QuerySnapshot initSnapshot;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();

    Future.delayed(Duration.zero).then((value) async {
      userId = Provider.of<User>(context, listen: false).getUserId;
      // print('userid ------> $userId');
      peerId = widget.person.uid;
      if (userId.hashCode <= peerId.hashCode)
        groupChatId = '$userId-$peerId';
      else
        groupChatId = '$peerId-$userId';
    });
  }

  void fetchInitData() async {
    final snapshot = await Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .limit(20)
        .getDocuments();

    setState(() {
      initSnapshot = snapshot;
      snapshot.documents.forEach((element) {
        // dummyTexts.add({
        //   'text': element['content'],
        //   'isMe': element['fromId'] == userId,
        // });
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    if (_initLoaded) {
      fetchInitData();
      _initLoaded = false;
    }

    _initLoaded = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
  }

  void onMessageSend(String content) async {
    if (content.trim() != '') _textEditingController.clear();
    DateTime time = DateTime.now();
    // String groupChatId = await getGroupChatId();
    var documentRef = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentRef, {
        'fromId': userId,
        'toId': peerId,
        'date': DateTime.now().toIso8601String(),
        'timeStamp': time.millisecondsSinceEpoch.toString(),
        'content': content,
      });
    });

    final userContacts = Provider.of<User>(context, listen: false).getContacts;
    if (!userContacts.contains(peerId)) {
      Provider.of<User>(context, listen: false).addToContacts(peerId);
      var userDocumentRef =
          Firestore.instance.collection('users').document(userId);
      userDocumentRef.setData({
        'contacts': userContacts,
      }, merge: true);

      var peerDcoumentRef =
          Firestore.instance.collection('users').document(peerId);
      final peerRef = await peerDcoumentRef.get();

      var peerContacts = [];
      peerRef.data['contacts'].forEach((elem) => peerContacts.add(elem));
      peerContacts.add(userId);

      peerDcoumentRef.setData({
        'contacts': peerContacts,
      }, merge: true);

      Person person = Person(
        uid: peerId,
        name: peerRef['username'],
        imageUrl: peerRef['imageUrl'],        
      );
      // Message message = Message(content: content, timeStamp: time, fromId: )
      InitChatData initChatData = InitChatData();
    }
  }

  Widget _buildMessageItem(DocumentSnapshot snapshot) {
    final message = Message.fromSnapshot(snapshot);
    return MessageBubble(
      message: message,
      isMe: message.fromId == userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('uid: -------> ${widget.person.uid}');
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: Hexcolor('#ECE5DD'),
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white.withOpacity(0.87),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                radius: 20,
                backgroundImage: widget.person.imageUrl != null
                    ? CachedNetworkImageProvider(widget.person.imageUrl)
                    : null,
                child:
                    widget.person.imageUrl == null ? Icon(Icons.person) : null,
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.person.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.87),
                    ),
                  ),
                  Text(
                    'tap for more info',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  )
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.call),
              onPressed: () {},
            ),
            IconButton(
              icon: Transform.rotate(
                angle: -pi / 4,
                child: Icon(Icons.attach_file),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            )
          ],
        ),
        body:
            // _isLoading ? CircularProgressIndicator() :
            StreamBuilder(
          initialData: initSnapshot,
          stream: Firestore.instance
              .collection('messages')
              .document(groupChatId)
              .collection(groupChatId)
              .orderBy('timeStamp', descending: true)
              // .limit(20)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            else {
              // messages = snapshot.data.documents;
              // print('messages: ------> $messages');
              return LayoutBuilder(
                builder: (ctx, constraints) {
                  // print(constraints.maxWidth);
                  return Column(
                    children: [
                      Flexible(
                        child: ListView.separated(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (ctx, i) {
                            return _buildMessageItem(
                                snapshot.data.documents[i]);
                          },
                          separatorBuilder: (_, __) {
                            return SizedBox(height: 10);
                          },
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth,
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white.withOpacity(0.9),
                              ),
                              height: 45,
                              width: constraints.maxWidth - 70,
                              child: TextField(
                                focusNode: _textFieldFocusNode,
                                controller: _textEditingController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.go,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.tag_faces,
                                    color: Colors.black.withOpacity(0.4),
                                    size: 30,
                                  ),
                                  hintText: 'Type a message',
                                  hintStyle: kChatItemSubtitleStyle,
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    // dummyTexts.add({
                                    //   'text': value,
                                    //   'isMe': true,
                                    // });
                                    _textEditingController.clear();
                                    _scrollController.animateTo(
                                        _scrollController
                                                .position.minScrollExtent -
                                            50,
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeIn);
                                  });
                                  onMessageSend(value);
                                  FocusScope.of(context)
                                      .requestFocus(_textFieldFocusNode);
                                },
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                    color: Hexcolor('#075E54'),
                                    borderRadius: BorderRadius.circular(45)),
                                child: Center(
                                  child: Icon(
                                    Icons.mic,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  MessageBubble({
    @required this.message,
    @required this.isMe,
  });

  bool didExceedMaxLines(double maxWidth) {
    final span = TextSpan(text: message.content);
    final tp =
        TextPainter(text: span, maxLines: 1, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth);
    print('maxwidth' + maxWidth.toString());

    return tp.didExceedMaxLines;
  }

  String getDate() {
    int hour = message.timeStamp.hour;
    int min = message.timeStamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();

    return '$hRes:$mRes';
  }

  List<Widget> _buildBubbleContent() {
    return [
      Text(
        message.content,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black.withOpacity(0.95),
        ),
      ),
      SizedBox(width: 10),
      Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              getDate(),
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 5),
            Icon(
              Icons.done_all,
              color: Hexcolor('##34B7F1'),
              size: 19,
            ),
          ]
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: isMe ? EdgeInsets.only(left: 80) : EdgeInsets.only(right: 80),
      child: Material(
        borderRadius: BorderRadius.circular(5),
        elevation: 2,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: isMe
                    ? BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      )
                    : BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                color:
                    isMe ? Hexcolor('##DCF8C6') : Colors.white.withOpacity(0.9),
              ),
              padding: const EdgeInsets.all(8.0),
              child: didExceedMaxLines(constraints.maxWidth - 80)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _buildBubbleContent(),
                    )
                  : Wrap(
                      children: _buildBubbleContent(),
                    ),
            );
          },
        ),
      ),
    );
  }
}
