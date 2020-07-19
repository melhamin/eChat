import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/widgets/app_bar.dart';

class ChatItemScreen extends StatefulWidget {
  final InitChatData chatData;
  ChatItemScreen(this.chatData);

  @override
  _ChatItemScreenState createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> {
  DB db;
  List<Message> initData = [];

  DocumentSnapshot lastSnapshot;
  var lastSeen;

  TextEditingController _textEditingController;
  ScrollController _scrollController;
  FocusNode _textFieldFocusNode;

  String userId;
  String peerId;
  String groupChatId;
  var messages;

  QuerySnapshot initSnapshot;
  File _image;
  final picker = ImagePicker();

  KeyboardVisibilityNotification _keyboard;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    db = DB();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();

    _keyboard = KeyboardVisibilityNotification();

    // used for animating body when keyboard appeares
    _keyboard.addNewListener(onChange: (visible) {
      setState(() {
        isVisible = visible;
      });
    });

    initData = widget.chatData.messages;

    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        userId = Provider.of<User>(context, listen: false).getUserId;
        // print('userid ------> $userId');\
        if(widget.chatData.messages.isNotEmpty)
        lastSeen =
            widget.chatData.messages[widget.chatData.messages.length - 1];
        peerId = widget.chatData.person.uid;
        if (userId.hashCode <= peerId.hashCode)
          groupChatId = '$userId-$peerId';
        else
          groupChatId = '$peerId-$userId';
      });
    });
  }

  @override
  void didChangeDependencies() {
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
    // Create a document for new message on firestore
    var docRef = db.createMessageDocument(
        groupChatId, time.millisecondsSinceEpoch.toString());

    db.addNewMessage(docRef, {
      'fromId': userId,
      'toId': peerId,
      'date': time.toIso8601String(),
      'timeStamp': time.millisecondsSinceEpoch.toString(),
      'content': content,
      'isSeen': false,
      'type': type,
    });

    print('gourp id============> $groupChatId');

    final userContacts = Provider.of<User>(context, listen: false).getContacts;
    // add user to contacts if not already in contacts
    if (!userContacts.contains(peerId)) {      
      Provider.of<User>(context, listen: false).addToContacts(peerId);      
      db.updateContacts(userId, userContacts);

      // add to peer contacts too
      var userRef = await db.addToPeerContacts(peerId, userId);

      Person person = Person.fromSnapshot(userRef);
      Message message = Message(
          content: content, timeStamp: time, fromId: userId, toId: peerId);
      InitChatData initChatData = InitChatData(
        groupId: groupChatId,
        person: person,
        messages: [message],
      );
      Provider.of<User>(context, listen: false).addToInitChats(initChatData);
    } else {      
      Provider.of<User>(context, listen: false).bringChatToTop(groupChatId);
    }
  }

  Widget _buildMessageItem(Message message, bool withoutImage) {
    return MessageBubble(
      message: message,
      isMe: message.fromId == userId,
      peer: widget.chatData.person,
      withoutImage: withoutImage,
    );
  }

  void onSend(String msgContent) {
    if (msgContent.isEmpty) return;
    setState(() {
      _textEditingController.clear();
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    });
    onMessageSend('0', msgContent);
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  stream() {
    var snapshots;
    if (lastSnapshot != null) {
      // lastSnapshot is set as the last message recieved or sent
      // if it is set(users interacted) fetch only messages added after this message
      snapshots = db.getSnapshotsAfter(groupChatId, lastSnapshot);
    } else {
      // otherwise fetch a limited number of messages(10)
      snapshots = db.getSnapshotsWithLimit(groupChatId, 10);
    }
    return snapshots;
  }

  addNewMessages(AsyncSnapshot<dynamic> snapshots) {
    if (snapshots.hasData) {
      int length = snapshots.data.documents.length;
      if (length != 0) {
        // set lastSnapshot to last message fetched to later use
        // for fetching new messages only after this snapshot
        lastSnapshot = snapshots.data.documents[length - 1];
        // print('lengt---------->> $length');
      }

      //TODO find a better way of seen status
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
          db.updateMessageField(snapshot, 'isSeen', true);
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Hexcolor('#202020'),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 5),
          child: MyAppBar(widget.chatData.person),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
            child: Container(
              color: Hexcolor('#121212'),
              child: StreamBuilder(
                  stream: stream(),
                  builder: (ctx, snapshots) {                    
                    addNewMessages(snapshots);
                    return LayoutBuilder(
                      builder: (ctx, constraints) {
                        return Column(
                          children: [
                            Flexible(
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                reverse: true,
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10, bottom: 10),
                                itemCount: initData.length,
                                itemBuilder: (ctx, i) {
                                  return _buildMessageItem(
                                    initData[i],
                                    (i != 0 &&
                                        initData[i - 1].fromId ==
                                            peerId), // show peer image only one in a series
                                  );
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
                                  SizedBox(width: 5),
                                  CupertinoButton(
                                    padding: const EdgeInsets.all(0),
                                    child: Icon(Icons.camera_alt,
                                        size: 27,
                                        color: Theme.of(context).accentColor),
                                    onPressed: () => getImage(),
                                  ),
                                  Flexible(
                                    child: TextField(
                                      style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              Colors.white.withOpacity(0.95)),
                                      focusNode: _textFieldFocusNode,
                                      controller: _textEditingController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.go,
                                      cursorColor:
                                          Theme.of(context).accentColor,
                                      keyboardAppearance: Brightness.dark,
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
                                  CupertinoButton(
                                    padding: const EdgeInsets.all(0),
                                    child: Icon(Icons.send,
                                        size: 30,
                                        color: Theme.of(context).accentColor),
                                    onPressed: () =>
                                        onSend(_textEditingController.text),
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: isVisible
                                  ? MediaQuery.of(context).viewInsets.bottom
                                  : 0,
                              // margin: isVisible
                              //     ? EdgeInsets.only(
                              //         bottom: MediaQuery.of(context)
                              //             .viewInsets
                              //             .bottom)
                              //     : EdgeInsets.only(bottom: 0),
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
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Person peer;
  final bool withoutImage;
  MessageBubble({
    @required this.message,
    @required this.isMe,
    @required this.peer,
    @required this.withoutImage,
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

  List<Widget> _buildBubbleContent(BuildContext context, bool multiLine) {
    return [
      Padding(
        padding: multiLine
            ? const EdgeInsets.only(left: 12, right: 12, top: 12)
            : const EdgeInsets.all(12.0),
        child: SelectableText(
          message.content,
          style: TextStyle(
            fontSize: 17,
            color: kBaseWhiteColor,
          ),
        ),
      ),
      SizedBox(width: 10),
      FittedBox(
        child: Padding(
          padding: multiLine
              ? const EdgeInsets.only(right: 10, bottom: 10, top: 5)
              : const EdgeInsets.only(top: 20, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                getTime(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              if (isMe)
                Row(
                  children: [
                    SizedBox(width: 5),
                    Icon(
                      Icons.done_all,
                      color: (message.isSeen != null && message.isSeen)
                          ? Theme.of(context).accentColor
                          : Colors.white.withOpacity(0.35),
                      size: 19,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildWithoutImage(BuildContext context, BoxConstraints constraints) {
    bool isMultiLine = didExceedMaxLines(constraints.maxWidth * 0.75 - 90);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: isMe ? null : Border.all(color: Hexcolor('#303030')),
        color: isMe ? Hexcolor('#303030') : Hexcolor('#121212'),
      ),
      child: isMultiLine
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildBubbleContent(context, isMultiLine),
            )
          : Wrap(
              children: _buildBubbleContent(context, isMultiLine),
            ),
    );
  }

  Widget _buildWithImage(BuildContext context, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        withoutImage
            ? SizedBox(width: 30)
            : Flexible(
                flex: 1,
                child: CircleAvatar(
                  backgroundColor: Hexcolor('#202020'),
                  backgroundImage: peer.imageUrl == null || peer.imageUrl == ''
                      ? null
                      : CachedNetworkImageProvider(peer.imageUrl),
                  child: peer.imageUrl == null || peer.imageUrl == ''
                      ? Icon(Icons.person, color: kBaseWhiteColor)
                      : null,
                  radius: 15,
                ),
              ),
        SizedBox(width: 5),
        Flexible(
          flex: 3,
          child: _buildWithoutImage(context, constraints),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: isMe ? EdgeInsets.only(left: 50) : EdgeInsets.only(right: 50),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return !isMe
              ? _buildWithImage(context, constraints)
              : _buildWithoutImage(context, constraints);
        },
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
