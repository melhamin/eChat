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
import 'package:whatsapp_clone/database/storage.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/widgets/app_bar.dart';
import 'package:whatsapp_clone/widgets/image_view.dart';

class ChatItemScreen extends StatefulWidget {
  final InitChatData chatData;
  ChatItemScreen(this.chatData);

  @override
  _ChatItemScreenState createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> {
  DB db;
  List<dynamic> initData = [];

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
  bool _mediaSelected = false;

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

    initData = [...widget.chatData.messages];

    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        userId = Provider.of<User>(context, listen: false).getUserId;
        // print('userid ------> $userId');\
        if (widget.chatData.messages.isNotEmpty)
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

  Message mediaMsg;

  void onMessageSend(String type, String content) async {
    if (content != '') _textEditingController.clear();
    DateTime time = DateTime.now();
    final newMessage = Message(
      content: content,
      fromId: userId,
      toId: peerId,
      timeStamp: time,
      isSeen: false,
      type: type,
      mediaUrl: null,
      uploadFinished: false,
    );
    initData.insert(0, newMessage);

    if (type == '1') mediaMsg = newMessage;

    if (type == '0') {
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
        'mediaUrl': '',
        'uploadFinished': true,
      });
    }

    final userContacts = Provider.of<User>(context, listen: false).getContacts;
    // add user to contacts if not already in contacts
    if (!userContacts.contains(peerId)) {
      Provider.of<User>(context, listen: false).addToContacts(peerId);
      db.updateContacts(userId, userContacts);

      // add to peer contacts too
      var userRef = await db.addToPeerContacts(peerId, userId);

      Person person = Person.fromSnapshot(userRef);
      Message message = Message(
        content: content,
        timeStamp: time,
        fromId: userId,
        toId: peerId,
        isSeen: false,
        mediaUrl: null,
        type: type,
        uploadFinished: false,
      );
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

  void onUploadFinished(String url) {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (mediaMsg == null) print('************mediamsg is null************');
    if (mediaMsg != null)
      setState(() {
        var msg =
            initData.firstWhere((elem) => elem.timeStamp == mediaMsg.timeStamp);
        msg.mediaUrl = url;
        msg.uploadFinished = true;

        final time = DateTime.now();
        var docRef = db.createMessageDocument(
            groupChatId, time.millisecondsSinceEpoch.toString());

        db.addNewMessage(docRef, {
          'fromId': userId,
          'toId': peerId,
          'date': mediaMsg.timeStamp.toIso8601String(),
          'timeStamp': mediaMsg.timeStamp.millisecondsSinceEpoch.toString(),
          'content': mediaMsg.content,
          'isSeen': false,
          'type': '1',
          'mediaUrl': url,
          'uploadFinished': true,
        });
      });
    // });
  }

  Widget _buildMessageItem(Message message, bool withoutImage) {
    if (message.type == '1') {
      if (message.mediaUrl == null || !message.uploadFinished)
        return ImageUploadingBubble(
            groupId: groupChatId,
            image: _image,
            time: message.timeStamp,
            onUploadFinished: onUploadFinished);
      else
        return MessageBubble(
          message: message,
          isMe: message.fromId == userId,
          peer: widget.chatData.person,
          withoutImage: withoutImage,
        );
    }
    return MessageBubble(
      message: message,
      isMe: message.fromId == userId,
      peer: widget.chatData.person,
      withoutImage: withoutImage,
    );
  }

  void onSend(String msgContent) {
    if (!_mediaSelected) {
      if (msgContent.isEmpty) return;
      setState(() {
        _textEditingController.clear();
        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      });
      onMessageSend('0', msgContent);
    } else {
      print('media selected =========> $_mediaSelected');
      if (msgContent.trim().isEmpty) msgContent = null;
      onMessageSend('1', msgContent);
      setState(() {
        _mediaSelected = false;
      });
    }
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
      _mediaSelected = true;
    });
    // _showMediaPreview();
  }

  Widget _showSelectedMediaPreview(MediaQueryData mq) {
    return Scaffold(
        body: Container(
      constraints: BoxConstraints(
        maxHeight: mq.size.height,
      ),
      color: Hexcolor('#121212'),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  child: Icon(Icons.close, color: kBaseWhiteColor, size: 25),
                  onPressed: () => setState(() => _mediaSelected = false),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: constraints.maxHeight * 0.8 - 35,
                width: constraints.maxWidth,
                child: Image.file(_image, fit: BoxFit.cover),
              ),
              Spacer(),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                decoration: BoxDecoration(
                    color: Hexcolor('#303030'),
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    Flexible(
                      child: TextField(
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.95)),
                        focusNode: _textFieldFocusNode,
                        controller: _textEditingController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        cursorColor: Theme.of(context).accentColor,
                        keyboardAppearance: Brightness.dark,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          border: InputBorder.none,
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        onSubmitted: (value) {
                          onSend(value);
                          // Navigator.of(context).pop();
                        },
                      ),
                    ),
                    // Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: Icon(Icons.send,
                          size: 30, color: Theme.of(context).accentColor),
                      onPressed: () => onSend(_textEditingController.text),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  bool beWithoutDetails(int i) {
    return (i != 0 &&
        initData[i - 1].fromId ==
            peerId); // show peer image only once in a series of nessages
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      bottom: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Hexcolor('#202020'),
        appBar: PreferredSize(
          preferredSize: _mediaSelected
              ? Size.fromHeight(0)
              : Size.fromHeight(kToolbarHeight + 5),
          child: MyAppBar(widget.chatData.person),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _mediaSelected
              ? _showSelectedMediaPreview(mq)
              : ClipRRect(
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
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      controller: _scrollController,
                                      reverse: true,
                                      padding: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 10,
                                          bottom: 10),
                                      itemCount: initData.length,
                                      itemBuilder: (ctx, i) {
                                        return _buildMessageItem(
                                          initData[i],
                                          beWithoutDetails(
                                              i), // show peer image only one in a series
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
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 5),
                                        CupertinoButton(
                                          padding: const EdgeInsets.all(0),
                                          child: Icon(Icons.camera_alt,
                                              size: 27,
                                              color: Theme.of(context)
                                                  .accentColor),
                                          onPressed: () => getImage(),
                                        ),
                                        Flexible(
                                          child: TextField(
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white
                                                    .withOpacity(0.95)),
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
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            onSubmitted: (value) =>
                                                onSend(value),
                                          ),
                                        ),
                                        // Spacer(),
                                        CupertinoButton(
                                          padding: const EdgeInsets.all(0),
                                          child: Icon(Icons.send,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .accentColor),
                                          onPressed: () => onSend(
                                              _textEditingController.text),
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    height: isVisible
                                        ? MediaQuery.of(context)
                                            .viewInsets
                                            .bottom
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

  Widget _buildSeenStatus(BuildContext context) => Row(
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
      );

  Widget _buildBottomDetails(
          BuildContext context, BoxConstraints constraints) =>
      Container(
        padding: const EdgeInsets.all(5),
        height: 30,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.01),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: _buildSeenStatus(context),
      );

  Widget _buildMediaText(BuildContext context, BoxConstraints constraints) {
    bool isMultiLine = didExceedMaxLines(constraints.maxWidth - 90);
    if (isMultiLine) print('isMultiline -----------> ${message.content}');
    return Material(
      elevation: 0,
      color: Colors.transparent,
        child: isMultiLine
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildBubbleContent(context, isMultiLine, true),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildBubbleContent(context, isMultiLine, true),
              ));
  }

  Widget _buildAvatar() => CircleAvatar(
        backgroundColor: Hexcolor('#202020'),
        backgroundImage: peer.imageUrl == null || peer.imageUrl == ''
            ? null
            : CachedNetworkImageProvider(peer.imageUrl),
        child: peer.imageUrl == null || peer.imageUrl == ''
            ? Icon(Icons.person, color: kBaseWhiteColor)
            : null,
        radius: 15,
      );

  Widget _buildMediaBubble(BuildContext context) {
    // print('media msg content --------------> ${message.content}');
    final mq = MediaQuery.of(context);
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) Flexible(flex: 1, child: _buildAvatar()),
        if (!isMe) SizedBox(width: 5),
        Flexible(
          flex: 6,
          child: Hero(
            tag: message.mediaUrl,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImageView(message.mediaUrl),
                ));
              },
              child: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Hexcolor('#303030')),
                    color: isMe ? Hexcolor('#202020') : Hexcolor('#121212'),
                  ),
                  padding: const EdgeInsets.all(5),
                  constraints: BoxConstraints(
                    minWidth: mq.size.width * 0.7,
                    maxWidth: mq.size.width * 0.7,
                    minHeight: mq.size.height * 0.35,
                    // maxHeight: mq.size.height * 0.35,
                  ),
                  child: LayoutBuilder(
                    builder: (cts, constraints) {
                      // print('content ======> ${message.content}');
                      if (message.content == null || message.content.isEmpty)
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                constraints: BoxConstraints(
                                  minWidth: mq.size.width * 0.7,
                                  maxWidth: mq.size.width * 0.7,
                                  minHeight: mq.size.height * 0.35,
                                  maxHeight: mq.size.height * 0.35,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: message.mediaUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: _buildBottomDetails(context, constraints),
                            ),
                          ],
                        );
                      // print(' (((((((((((( in else -=======> ');
                      return Wrap(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: mq.size.width * 0.7,
                                maxWidth: mq.size.width * 0.7,
                                minHeight: mq.size.height * 0.35,
                                maxHeight: mq.size.height * 0.35,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: message.mediaUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Container(
                          //   child: Text(message.content),
                          // ),
                          _buildMediaText(context, constraints),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getContentPadding(bool multiLine, bool media) {
    var contentPadding;
    // if(multiLine && !media) padding = const EdgeInsets.only(left: 12, right: 12, top: 12);
    // else padding = const EdgeInsets.only(left: 5, right: 5, top: 9);

    if (multiLine) {
      if (!media)
        contentPadding = const EdgeInsets.only(left: 12, right: 12, top: 12);
      else
        contentPadding = const EdgeInsets.all(5.0);
    } else {
      if (media)
        contentPadding = const EdgeInsets.only(top: 5, bottom: 5, left: 5);
      else
        contentPadding = const EdgeInsets.all(12.0);
    }
    return contentPadding;
  }

  getSeenStatusPadding(bool multiLine, bool media) {
    var seenStatusPadding;
    if (isMe && !multiLine) if (media)
      seenStatusPadding = const EdgeInsets.only(top: 20, right: 5);
    else
      seenStatusPadding = const EdgeInsets.only(top: 20, right: 10);
    else {
      if (media)
        seenStatusPadding = const EdgeInsets.only(top: 5);
      else
        seenStatusPadding = const EdgeInsets.only(bottom: 5, top: 5, right: 12);
    }
    return seenStatusPadding;
  }

  List<Widget> _buildBubbleContent(BuildContext context, bool multiLine,
      [bool media = false]) {
    var contentPadding = getContentPadding(multiLine, media);
    var seenStatusPadding = getSeenStatusPadding(multiLine, media);

    return [
      Padding(
        padding: contentPadding,
        child: SelectableText(
          message.content,
          style: TextStyle(
            fontSize: 17,
            color: kBaseWhiteColor,
          ),
        ),
      ),
      if (media && !multiLine)
        // Text('ksdljfaklfjakfjaklfjakfjkafjkajf'),
        Spacer(),
      FittedBox(
        child: Padding(
          padding: seenStatusPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                getTime(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              // if(!multiLine)
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
    bool isMultiLine;
    if (isMe)
      isMultiLine = didExceedMaxLines(constraints.maxWidth - 90);
    else
      isMultiLine = didExceedMaxLines(constraints.maxWidth - 200);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: isMe ? null : Border.all(color: Hexcolor('#303030')),
        color: isMe ? Hexcolor('#303030') : Hexcolor('#121212'),
      ),
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth,
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
    final mq = MediaQuery.of(context);
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: isMe ? EdgeInsets.only(left: 50) : EdgeInsets.only(right: 50),
      constraints: BoxConstraints(
        maxWidth: isMe ? mq.size.width * 0.8 : mq.size.width * 0.9,
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          if (message.type == '0') {
            return !isMe
                ? _buildWithImage(context, constraints)
                : _buildWithoutImage(context, constraints);
          } else {
            return _buildMediaBubble(context);
          }
        },
      ),
    );
  }
}

class ImageUploadingBubble extends StatefulWidget {
  final String groupId;
  final File image;
  final DateTime time;
  final Function onUploadFinished;
  ImageUploadingBubble({
    @required this.groupId,
    @required this.image,
    @required this.time,
    @required this.onUploadFinished,
  });
  @override
  _ImageUploadingBubbleState createState() => _ImageUploadingBubbleState();
}

class _ImageUploadingBubbleState extends State<ImageUploadingBubble> {
  Storage _storage;
  StorageUploadTask _uploadTask;

  bool uploadStarted = false;
  String path;
  var timestamp;

  @override
  void initState() {
    super.initState();
    _storage = Storage();
    setState(() {
      timestamp = widget.time.millisecondsSinceEpoch;
      path = 'ChatsMedia/${widget.groupId}/$timestamp.png';
      _uploadTask = _storage.getUploadTask(widget.image, path);
    });
  }

  void onUploadCompleted() async {
    var url =
        await _storage.getUrl('ChatsMedia/${widget.groupId}', '$timestamp');
    widget.onUploadFinished(url);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Hexcolor('#202020'),
        ),
        padding: const EdgeInsets.all(5),
        height: mq.size.height * 0.35,
        width: mq.size.width * 0.7,
        child: LayoutBuilder(
          builder: (cts, constraints) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.file(
                      widget.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                StreamBuilder<StorageTaskEvent>(
                  stream: _uploadTask.events,
                  builder: (ctx, snapshots) {
                    if (_uploadTask.isComplete && _uploadTask.isSuccessful) {
                      onUploadCompleted();
                    }
                    return _uploadTask.isInProgress
                        ? Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.54),
                            child: Center(child: CupertinoActivityIndicator()),
                          )
                        : Container(height: 0, width: 0);
                  },
                ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(10),
                //   child: Container(
                //     height: double.infinity,
                //     width: double.infinity,
                //     child: Image.file(
                //       widget.image,
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   bottom: 0,
                //   right: 0,
                //   child: _buildBottomDetails(context, constraints),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
