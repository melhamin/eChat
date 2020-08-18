import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/reply_message_preview.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/selected_image_preview.dart';
import 'package:whatsapp_clone/utils/utils.dart';
import 'package:whatsapp_clone/widgets/app_bar.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/media_uploading_bubble.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/chat_bubble.dart';

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

  // variable for handling image selection
  File _image;
  bool _mediaSelected = false;
  final picker = ImagePicker();
  Message mediaMsg;

  // resize the body with animation when keyboard opens
  // normally it just pops up without transition
  KeyboardVisibilityNotification _keyboard;
  bool isVisible = false;
  bool scrolledAbove = false;

  // for fetching new chats
  CancelableOperation paginateOperation;
  LoaderStatus loaderStatus = LoaderStatus.STABLE;
  bool _isFetchingNewChats = false;

  // for controlling reply messsages
  GlobalKey textFieldKey = GlobalKey();

  FocusNode bodyFocusNode;

  @override
  void initState() {
    super.initState();
    print('initcalled =============');
    db = DB();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();
    _keyboard = KeyboardVisibilityNotification();

    bodyFocusNode = FocusNode();

    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.minScrollExtent + 200) {
    //     setState(() {
    //       scrolledAbove = true;
    //     });
    //   }
    // });

    // used for animating body when keyboard appeares
    _keyboard.addNewListener(onChange: (visible) {
      setState(() {
        isVisible = visible;
      });
    });

    // get user and chat details
    userId = widget.chatData.userId;
    peerId = widget.chatData.peerId;
    groupChatId = widget.chatData.groupId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    bodyFocusNode.dispose();
    super.dispose();
  }

  void onMessageSend(String type, String content,
      {ReplyMessage replyDetails}) async {
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
      reply: replyDetails,
    );
    widget.chatData.messages.insert(0, newMessage);

    // print('reply content ----------------> ${replyContent}');

    if (type == '1') mediaMsg = newMessage;

    if (type == '0') {
      db.addNewMessage(groupChatId, time, {
        'fromId': userId,
        'toId': peerId,
        'date': time.toIso8601String(),
        'timeStamp': time.millisecondsSinceEpoch.toString(),
        'content': content,
        'isSeen': false,
        'type': type,
        'mediaUrl': '',
        'uploadFinished': true,
        'reply':
            replyDetails != null ? ReplyMessage.toJson(replyDetails) : null,
      });
    }

    final userContacts = Provider.of<User>(context, listen: false).getContacts;
    // add user to contacts if not already in contacts
    if (!userContacts.contains(peerId)) {
      Provider.of<User>(context, listen: false).addToContacts(peerId);
      db.updateContacts(userId, userContacts);

      // add to peer contacts too
      var userRef = await db.addToPeerContacts(peerId, userId);

      // add reply color pair
      int n = Random().nextInt(replyColors.length);
      final replyColorPair = replyColors[n];

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
        reply: replyDetails,
      );
      InitChatData initChatData = InitChatData(
        userId: userId,
        peerId: peerId,
        groupId: groupChatId,
        person: person,
        messages: [message],
        replyColorPair: replyColorPair,
      );
      Provider.of<User>(context, listen: false).addToInitChats(initChatData);
    } else {
      Provider.of<User>(context, listen: false).bringChatToTop(groupChatId);
    }
  }

  void onUploadFinished(String url) {
    if (mediaMsg == null) print('************mediamsg is null************');
    if (mediaMsg != null) {
      var msg = widget.chatData.messages
          .firstWhere((elem) => elem.timeStamp == mediaMsg.timeStamp);
      msg.mediaUrl = url;
      msg.uploadFinished = true;

      final time = DateTime.now();

      db.addNewMessage(groupChatId, time, {
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
      db.addMediaUrl(groupChatId, url, mediaMsg);
    }
  }

  Widget _buildMessageItem(Message message, bool withoutAvatar, bool last,
      bool first, bool isMiddle) {
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
          withoutAvatar: withoutAvatar,
          onReplyPressed: onReplyPressed,
        );
    }
    return ChatBubble(
      message: message,
      isMe: message.fromId == userId,
      peer: widget.chatData.person,
      withoutAvatar: withoutAvatar,
      onReplyPressed: onReplyPressed,
    );
  }

  Message msgToReply;
  bool replied = false;
  void onReplyPressed(Message msg) async {
    _textFieldFocusNode.requestFocus();
    msgToReply = msg;
    replied = true;
    if (isVisible) {
      // update input field state to show reply preview
      textFieldKey.currentState.setState(() {});
      // add postframcallback and reset values
      // if reseted before the statefuilbuilder will also be rebuilt and reseted
      // await Future.delayed(Duration.zero).then((value) {
      //   // reset values to close reply preview when message sent
      //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //     replied = false;
      //     msgToReply = null;
      //   });
      // });
    }
  }

  void onSend(String msgContent, {ReplyMessage replyDetails}) {
    if (!_mediaSelected) {
      if (msgContent.isEmpty) return;
      _textEditingController.clear();
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      onMessageSend('0', msgContent, replyDetails: replyDetails);
    } else {
      if (msgContent.trim().isEmpty) msgContent = null;
      onMessageSend('1', msgContent, replyDetails: replyDetails);
      setState(() {
        _mediaSelected = false;
      });
    }
    // remove reply preview after send if the message is replied
    if (replyDetails != null) {
      replied = false;
      msgToReply = null;
    }
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  Stream<QuerySnapshot> stream() {
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

  // updates seen status of peer messages
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

      if (s && newMsg.isSeen)
        for (int i = index; i >= 0; i--)
          if (widget.chatData.messages[i].fromId == userId)
            widget.chatData.messages[i].isSeen = true;
    }
  }

  // adds new messages to the list and updates seen status
  // on the database
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
          Message newMsg = Message.fromJson(snapshot);
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
          if (snapshot['fromId'] == peerId && !snapshot['isSeen']) {
            db.updateMessageField(snapshot, 'isSeen', true);
          }
        });
      }
    }
  }

  Future getImage() async {
    Utils.showImageSourceModal(context).then((value) async {
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

  Widget _buildChatArea() {
    return Flexible(
      child: NotificationListener(
        onNotification: onNotification,
        child: ListView.separated(
          addAutomaticKeepAlives: true,
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          reverse: true,
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          itemCount: widget.chatData.messages.length,
          itemBuilder: (ctx, i) {
            int length = widget.chatData.messages.length;
            return _buildMessageItem(
                widget.chatData.messages[i],
                ChatOps.withoutAvatar(
                    i, length, widget.chatData.messages, peerId),
                ChatOps.isLast(i, length, widget.chatData.messages),
                ChatOps.isFirst(i, length, widget.chatData.messages),
                ChatOps.isMiddle(i, length, widget.chatData.messages));
          },
          separatorBuilder: (_, i) {
            final msgs = widget.chatData.messages;
            int length = msgs.length;
            if ((i != length && msgs[i].fromId != msgs[i + 1].fromId) ||
                msgs[i].reply != null) return SizedBox(height: 15);
            return SizedBox(height: 5);
          },
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return StatefulBuilder(
      key: textFieldKey,
      builder: (ctx, thisState) {
        bool reply = false;
        Message repliedMessage;

        thisState(() {
          reply = replied;
          repliedMessage = msgToReply;
        });

        void send() {
          ReplyMessage replyDetails;
          if (repliedMessage != null) {
            replyDetails = ReplyMessage();
            replyDetails.replierId = userId;
            replyDetails.repliedToId = repliedMessage.fromId;
            if (repliedMessage.type == '0')
              replyDetails.content = repliedMessage.content;
            else
              replyDetails.content = repliedMessage.mediaUrl;
            replyDetails.type = repliedMessage?.type;
          }
          onSend(
            _textEditingController.text,
            replyDetails: replyDetails,
            // replyContent: replyContent,
            // replyMsgSenderId: replyMsgSenderId,
          );

          thisState(() {
            reply = false;
            repliedMessage = null;
          });
        }

        Widget _buildTextField() {
          return Flexible(
            child: TextField(
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.95)),
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
              onSubmitted: (_) => send(),
            ),
          );
        }

        Widget _buildReplyMessage() {
          return AnimatedContainer(
            padding: const EdgeInsets.only(left: 10),
            duration: Duration(milliseconds: 200),
            height: reply ? 70 : 0,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: reply
                    ? BorderSide(color: kBorderColor1)
                    : BorderSide(color: Colors.transparent),
              ),
            ),
            child: replied
                ? ReplyMessagePreview(
                    onCanceled: () => thisState(() {
                      replied = false;
                      repliedMessage = null;
                      reply = false;
                      msgToReply = null;
                    }),
                    repliedMessage: repliedMessage,
                    peerName: widget.chatData.person.name,
                    reply: reply,
                    userId: userId,
                    color: widget.chatData.replyColorPair.user,
                  )
                : Container(width: 0, height: 0),
          );
        }

        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Hexcolor('#303030'),
              borderRadius: reply
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )
                  : BorderRadius.circular(25)),
          // borderRadius: BorderRadius.circular(25)),
          child: Column(
            children: [
              _buildReplyMessage(),
              Row(
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
                    onPressed: send,
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels >=
          notification.metrics.maxScrollExtent - 40) {
        if (loaderStatus != null && loaderStatus == LoaderStatus.STABLE) {
          loaderStatus = LoaderStatus.LOADING;
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
    print('*************** build call ****************');
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
            FocusScope.of(context).requestFocus(bodyFocusNode);
          },
          child: _mediaSelected
              ? SelectedImagePreview(
                  image: _image,
                  onClosed: () => setState(() => _mediaSelected = false),
                  onSend: onSend,
                  textEditingController: _textEditingController,
                )
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

class ChatOps {
  // show peer avatar only once in a series of nessages
  static bool withoutAvatar(
      int i, int length, List<dynamic> messages, String peerId) {
    bool c1 = i != 0 && messages[i - 1].fromId == peerId;
    bool c2 = i != 0 && messages[i - 1].type != '1';
    return c1 && c2;
  }

  // for adding border radius to all sides except for bottomRight/bottomLeft
  // if last message in a series from same user
  static bool isLast(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId == messages[i].fromId;
    bool c2 = i != 0 && messages[i - 1].type != '1';
    return i == length - 1 || c1 && c2;
  }

  // for adding border radius to only topLeft/bottomLeft or topRight/bottomRight
  // if message is in the series of messages of one user
  static bool isMiddle(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId == messages[i].fromId;
    bool c2 = i != length - 1 && messages[i + 1].fromId == messages[i].fromId;
    return c1 && c2;
  }

  // opposite of isLast
  static bool isFirst(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId != messages[i].fromId;
    bool c2 = i != length - 1 && messages[i + 1].fromId == messages[i].fromId;
    return i == 0 || (c1 && c2);
  }
}
