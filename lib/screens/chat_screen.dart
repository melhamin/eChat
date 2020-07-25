import 'dart:io';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/widgets/app_bar.dart';
import 'package:whatsapp_clone/widgets/chat/media_uploading_bubble.dart';
import 'package:whatsapp_clone/widgets/chat/chat_bubble.dart';

enum LoaderStatus {
  STABLE,
  LOADING,
}

class ChatItemScreen extends StatefulWidget {
  final InitChatData chatData;
  ChatItemScreen(this.chatData);

  @override
  _ChatItemScreenState createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> {
  DB db;

  DocumentSnapshot lastSnapshot;

  TextEditingController _textEditingController;
  ScrollController _scrollController;
  FocusNode _textFieldFocusNode;

  String userId;
  String peerId;
  String groupChatId;

  QuerySnapshot initSnapshot;
  File _image;
  bool _mediaSelected = false;
  final picker = ImagePicker();

  KeyboardVisibilityNotification _keyboard;
  bool isVisible = false;

  bool scrolledAbove = false;

  CancelableOperation paginateOperation;
  LoaderStatus loaderStatus = LoaderStatus.STABLE;
  bool _isFetchingNewChats = false;

  @override
  void initState() {
    super.initState();
    db = DB();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();
    _keyboard = KeyboardVisibilityNotification();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent + 200) {
        setState(() {
          scrolledAbove = true;
        });
      }
    });

    // used for animating body when keyboard appeares
    _keyboard.addNewListener(onChange: (visible) {
      setState(() {
        isVisible = visible;
      });
    });

    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        userId = Provider.of<User>(context, listen: false).getUserId;
        // print('userid ------> $userId');\
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
    _scrollController.removeListener(() {});
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
    widget.chatData.messages.insert(0, newMessage);

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
        var msg = widget.chatData.messages
            .firstWhere((elem) => elem.timeStamp == mediaMsg.timeStamp);
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
    db.addMediaUrl(groupChatId, url, mediaMsg);
    // });
  }

  Widget _buildMessageItem(Message message, bool withoutImage) {
    if (message.type == '1') {
      if (message.mediaUrl == null || !message.uploadFinished)
        return MediaUploadingBubble(
          groupId: groupChatId,
          image: _image,
          time: message.timeStamp,
          onUploadFinished: onUploadFinished,
          message: message,
        );
      else
        return ChatBubble(
          message: message,
          isMe: message.fromId == userId,
          peer: widget.chatData.person,
          withoutImage: withoutImage,
        );
    }
    return ChatBubble(
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
      print('from last snapshot ------------> ${lastSnapshot.data['content']}');
      // lastSnapshot is set as the last message recieved or sent
      // if it is set(users interacted) fetch only messages added after this message
      snapshots = db.getSnapshotsAfter(groupChatId, lastSnapshot);
    } else {
      print('from limit ------------>');
      // otherwise fetch a limited number of messages(10)
      snapshots = db.getSnapshotsWithLimit(groupChatId, 10);
    }
    return snapshots;
  }

  void handleSeenStatusUpdateWhenFromPeer() {
    int index = -1;
    for (int i = 0; i < widget.chatData.messages.length; i++) {
      final item = widget.chatData.messages[i];
      if (i == widget.chatData.messages.length - 1) {
        index = i;
        break;
      } else {
        if (item.fromId == userId && item.isSeen) {
          index = i;
          break;
        }
      }
    }
    if (index != -1)
      for (int i = index; i >= 0; i--)
        widget.chatData.messages[i].isSeen = true;
  }

  void handleSeenStatusWhenFromMe(Message newMsg) {
    int index = -1;
    for (int i = 0; i < widget.chatData.messages.length; i++) {
      if (i == widget.chatData.messages.length - 1) {
        index = i;
        break;
      } else {
        if (widget.chatData.messages[i].fromId == userId &&
            widget.chatData.messages[i].isSeen) {
          index = i;
          break;
        }
      }
    }
    if (index != -1) {
      bool s =
          newMsg.timeStamp.isAfter(widget.chatData.messages[index].timeStamp);
      // || newMsg.timeStamp.isAtSameMomentAs(widget.chatData.messages[index].timeStamp);

      if (s && newMsg.isSeen)
        for (int i = index; i >= 0; i--)
          if (widget.chatData.messages[i].fromId == userId)
            widget.chatData.messages[i].isSeen = true;
    }
  }

  void addNewMessages(AsyncSnapshot<dynamic> snapshots) {
    if (snapshots.hasData) {
      int length = snapshots.data.documents.length;
      if (length != 0) {
        // set lastSnapshot to last message fetched to later use
        // for fetching new messages only after this snapshot
        lastSnapshot = snapshots.data.documents[length - 1];
      }

      // TODO fix seen update if from last snapshot***
      for (int i = 0; i < snapshots.data.documents.length; i++) {
        final snapshot = snapshots.data.documents[i];
        Future.doWhile(() {
          Message newMsg = Message.fromSnapshot(snapshot);
          if (widget.chatData.messages.isNotEmpty) {
            // add message to the list only if it's after the first item in the list
            if (newMsg.timeStamp
                .isAfter(widget.chatData.messages[0].timeStamp)) {
              widget.chatData.messages.insert(0, newMsg);

              // if message is from peer update seen status of all unseen messages
              if (newMsg.fromId == peerId) {
                handleSeenStatusUpdateWhenFromPeer();
              }
            } else {
              // if new snapshot is a message from this user, find the last seen message index
              if (newMsg.fromId == userId && newMsg.isSeen) {
                handleSeenStatusWhenFromMe(newMsg);
              }
              // }
            }
          }
          return false;
        }).then((value) {
          // Update isSeen of the message only if message is from peer
          if (snapshot['fromId'] == peerId) {
            db.updateMessageField(snapshot, 'isSeen', true);
          }
        });
      }
    }
  }

  Future<bool> showImageSourceModal() async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoButton(
            child:
                Text('Choose Photo', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CupertinoButton(
            child: Text('Take Photo', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
        cancelButton: CupertinoButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future getImage() async {
    showImageSourceModal().then((value) async {
      if (value != null) {
        _image = null;
        var pickedFile = await Utils.pickImage(
            value ? ImageSource.gallery : ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
            _mediaSelected = true;
          });
        }
      }
    });
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
                width: double.infinity,
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

  // show peer avatar only once in a series of nessages
  bool withoutAvatar(int i, int length) {
    bool c1 = i != 0 && widget.chatData.messages[i - 1].fromId == peerId;
    bool c2 = i != 0 && widget.chatData.messages[i - 1].type != '1';
    return c1 && c2;
  }

  Widget _buildChatArea() {
    return Flexible(
      child: NotificationListener(
        onNotification: onNotification,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          reverse: true,
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          itemCount: widget.chatData.messages.length,
          itemBuilder: (ctx, i) {
            return _buildMessageItem(
                widget.chatData.messages[i],
                withoutAvatar(
                    i,
                    widget.chatData.messages
                        .length) // show peer image only one in a series
                );
          },
          separatorBuilder: (_, __) {
            return SizedBox(height: 10);
          },
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Flexible(
      child: TextField(
        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.95)),
        focusNode: _textFieldFocusNode,
        controller: _textEditingController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.go,
        cursorColor: Theme.of(context).accentColor,
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
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
          color: Hexcolor('#303030'), borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 5),
          CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(Icons.camera_alt,
                size: 27, color: Theme.of(context).accentColor),
            onPressed: () => getImage(),
          ),
          _buildTextField(),
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
    );
  }

  bool onNotification(ScrollNotification notification) {
    final mq = MediaQuery.of(context);
    print('on notification -----------> ');
    if (notification is ScrollUpdateNotification) {
      // if (notification.metrics.pixels >=
      //     notification.metrics.minScrollExtent + mq.size.height * 0.5) {
      //   if (!scrolledAbove) setState(() => scrolledAbove = true);
      // } else {
      //   if (scrolledAbove) setState(() => scrolledAbove = false);
      // }
      if (notification.metrics.pixels >=
          notification.metrics.maxScrollExtent - 40) {
        if (loaderStatus != null && loaderStatus == LoaderStatus.STABLE) {
          // setState(() {
          loaderStatus = LoaderStatus.LOADING;
          //   _isFetchingNewChats = true;
          // });
          paginateOperation = CancelableOperation.fromFuture(
              widget.chatData.fetchNewChats().then(
            (_) {
              loaderStatus = LoaderStatus.STABLE;
              setState(() {
                _isFetchingNewChats = false;
              });
            },
          ));
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    print('last snp ============> ${widget.chatData.lastDoc['content']}');
    return SafeArea(
      bottom: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // resizeToAvoidBottomInset: false,
        backgroundColor: Hexcolor('#202020'),
        appBar: PreferredSize(
          preferredSize: _mediaSelected
              ? Size.fromHeight(0)
              : Size.fromHeight(kToolbarHeight + 5),
          child: MyAppBar(widget.chatData.person, widget.chatData.groupId),
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
                    child: Stack(
                      children: [
                        StreamBuilder(
                            stream: stream(),
                            builder: (ctx, snapshots) {
                              addNewMessages(snapshots);
                              return LayoutBuilder(
                                builder: (ctx, constraints) {
                                  return Column(
                                    children: [
                                      _buildChatArea(),
                                      _buildInputSection(),
                                      AnimatedContainer(
                                          duration: Duration(milliseconds: 100),
                                          height: isVisible
                                              ? MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom
                                              : 0),
                                    ],
                                  );
                                },
                              );
                            }),                        
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
  
}
