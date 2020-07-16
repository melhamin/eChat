import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/contact_details.dart';
import 'package:whatsapp_clone/widgets/app_bar.dart';

class ChatItemScreen extends StatefulWidget {
  final InitChatData chatData;
  ChatItemScreen(this.chatData);

  @override
  _ChatItemScreenState createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> {
  List<Message> initData = [];

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

  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();

    initData = widget.chatData.messages;

    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        userId = Provider.of<User>(context, listen: false).getUserId;
        // print('userid ------> $userId');
        peerId = widget.chatData.person.uid;
        if (userId.hashCode <= peerId.hashCode)
          groupChatId = '$userId-$peerId';
        else
          groupChatId = '$peerId-$userId';
      });
    });
  }

  // void fetchInitData() async {
  //   final snapshot = await Firestore.instance
  //       .collection('messages')
  //       .document(groupChatId)
  //       .collection(groupChatId)
  //       .limit(20)
  //       .getDocuments();

  //   setState(() {
  //     initSnapshot = snapshot;
  //     snapshot.documents.forEach((element) {
  //       // dummyTexts.add({
  //       //   'text': element['content'],
  //       //   'isMe': element['fromId'] == userId,
  //       // });
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  void didChangeDependencies() {
    if (_initLoaded) {
      // fetchInitData();
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

  void onMessageSend(String type, String content) async {
    if (content.trim() != '') _textEditingController.clear();
    DateTime time = DateTime.now();
    final newMessage = Message(
      content: content,
      fromId: userId,
      toId: peerId,
      timeStamp: time,
      isSeen: false,
      type: type,
    );
    initData.insert(0, newMessage);
    // String groupChatId = await getGroupChatId();
    var documentRef = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .document(time.millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentRef, {
        'fromId': userId,
        'toId': peerId,
        'date': time.toIso8601String(),
        'timeStamp': time.millisecondsSinceEpoch.toString(),
        'content': content,
        'isSeen': false,
        'type': type,
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
      Message message = Message(
          content: content, timeStamp: time, fromId: userId, toId: peerId);
      InitChatData initChatData = InitChatData(
        groupId: groupChatId,
        person: person,
        messages: [message],
      );
      Provider.of<User>(context, listen: false).addToInitChats(initChatData);
    }
  }

  Widget _buildMessageItem(dynamic snapshot) {
    final message = snapshot;
    // snapshot is Message ? snapshot : Message.fromSnapshot(snapshot);
    return MessageBubble(
      message: message,
      isMe: message.fromId == userId,
    );
  }

  void onSend(String value) {
    if (value.isEmpty) return;
    setState(() {
      _textEditingController.clear();
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    });
    onMessageSend('0', value);
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  DocumentSnapshot last;

  stream() {
    var snapshot;
    if (last != null) {
      print('in if ---------------->');
      // print('dat ----------> ${times[times.length - 1]['content']}');
      snapshot = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          // .limit(10)
          .startAtDocument(last)
          // .where('timeStamp', isGreaterThan: time)
          .orderBy('timeStamp')
          .snapshots();
      // print('if -------> snapshot length${snapshot.data.documents.length}');
    } else {
      print('in else ---------------->');
      snapshot = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .limit(10)
          // .startAfterDocument(times[0]);
          // // .where('timeStamp', isGreaterThan: time)
          .orderBy('timeStamp', descending: true)
          .snapshots();

      // print('else -------> snapshot length${snapshot.data.documents.length}');
    }

    return snapshot;
  }

  var lastSeen;

  addNewMessages(AsyncSnapshot<dynamic> snapshots) {
    if (snapshots.hasData) {
      int length = snapshots.data.documents.length;
      if (length != 0) {
        last = snapshots.data.documents[length - 1];
        print('lengt---------->> $length');
      }

      // initData.clear();
      for (int i = 0; i < length; i++) {
        final snapshot = snapshots.data.documents[i];
        Message newMsg = Message.fromSnapshot(snapshot);
        // if(newMsg.fromId == userId) newMsg.isSeen = true;
        if (initData.isNotEmpty) if (newMsg.timeStamp
            .isAfter(initData[0].timeStamp)) {
          initData.insert(0, newMsg);
        }
        if (newMsg.isSeen) lastSeen = newMsg;

        // Update isSeen of the message only if message is from peer
        if (snapshot['fromId'] == peerId) {
          Firestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshDoc =
                await transaction.get(snapshot.reference);
            await transaction.update(freshDoc.reference, {'isSeen': true});
          });
        }
      }

      if (lastSeen != null) {
        int index = initData.indexWhere((element) =>
            (lastSeen.fromId == userId &&
                lastSeen.timeStamp == element.timeStamp));
        // update data and set isSeen to true for messages before the message which is seen
        if (index != -1)
          for (int i = initData.length - 1; i >= index; i--)
            initData[i].isSeen = true;
      }
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }  

  @override
  Widget build(BuildContext context) {    
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: Hexcolor('#121212'),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 5),
          child: MyAppBar(widget.chatData.person),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Hexcolor('#202020'),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
                      child: StreamBuilder(
                stream: stream(),
                builder: (ctx, snapshots) {
                  // print('snapshot length ----------> ${snapshots.data.documents.length}');
                  addNewMessages(snapshots);
                  return LayoutBuilder(
                    builder: (ctx, constraints) {
                      return
                          // !snapshots.hasData
                          //     ? Center(
                          //         child: Text('Loading...'),
                          //       )
                          //     :
                          Column(
                        children: [
                          Flexible(
                            child: ListView.separated(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 10, bottom: 10),
                              itemCount: initData.length,
                              // snapshots.data.documents.length,
                              // !snapshot.hasData
                              // ? widget.chatData.messages.length
                              // : snapshot.data.documents.length,
                              itemBuilder: (ctx, i) {
                                return
                                    //  _buildMessageItem(
                                    //     snapshots.data.documents[i]);
                                    _buildMessageItem(initData[i]);
                                // !snapshot.hasData
                                //   ? widget.chatData.messages[i]
                                //   : snapshot.data.documents[i]);
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
                                color: Hexcolor('#303030'),
                                borderRadius: BorderRadius.circular(25)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // SizedBox(width: 5),
                                IconButton(
                                  icon: Icon(Icons.camera_alt),
                                  color: Colors.white.withOpacity(0.7),
                                  iconSize: 27,
                                  onPressed: () => getImage(),
                                ),
                                // SizedBox(width: 5),
                                Flexible(
                                  child: TextField(
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.95)),
                                    focusNode: _textFieldFocusNode,
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.go,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Type a message',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    onSubmitted: (value) => onSend(value),
                                  ),
                                ),
                                // Spacer(),
                                InkWell(
                                  child: Icon(Icons.send,
                                      size: 30,
                                      color: Theme.of(context).accentColor),
                                  splashColor: Colors.transparent,
                                  highlightColor: Theme.of(context).accentColor,
                                  onTap: () =>
                                      onSend(_textEditingController.text),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                // },
                ),
          ),
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
    // print('maxwidth' + maxWidth.toString());

    return tp.didExceedMaxLines;
  }

  String getTime() {
    int hour = message.timeStamp.hour;
    int min = message.timeStamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();

    return '$hRes:$mRes';
  }

  List<Widget> _buildBubbleContent(BuildContext context) {
    return [
      message.type == '0'
          ? Text(
              message.content,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black.withOpacity(0.97),
              ),
            )
          : Container(
              height: 100,
              width: 100,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: message.content,
              ),
            ),
      SizedBox(width: 10),
      Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              getTime(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 5),
            Icon(
              Icons.done_all,
              color: message.isSeen
                  ? Theme.of(context).accentColor
                  : Colors.black.withOpacity(0.35),
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
        borderRadius: isMe
            ? BorderRadius.only(
                topRight: Radius.circular(15),
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              )
            : BorderRadius.only(
                bottomRight: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
        elevation: 2,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: isMe
                    ? BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      )
                    : BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                color: isMe
                    ? Colors.white.withOpacity(0.87)
                    : Theme.of(context).accentColor,
              ),
              padding: const EdgeInsets.all(12.0),
              child: didExceedMaxLines(constraints.maxWidth - 80)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _buildBubbleContent(context),
                    )
                  : Wrap(
                      children: _buildBubbleContent(context),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class ImageUploader extends StatefulWidget {
  final File image;
  ImageUploader(this.image);
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://flutter-whatsapp-1ab58.appspot.com');
  StorageUploadTask _uploadTask;

  void _upload() {
    String path = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
    setState(() {
      _storage.ref().child(path).putFile(widget.image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
