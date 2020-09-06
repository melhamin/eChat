import 'dart:io';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/chat_data.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/reply_message.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/providers/chat.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/app_bar.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/chat_bubble.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/media_uploading_bubble.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/reply_message_preview.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/selected_media_preview.dart';
import 'package:whatsapp_clone/services/db.dart';
import 'package:whatsapp_clone/utils/utils.dart';

enum LoaderStatus {
  STABLE,
  LOADING,
}

class ChatItemScreen extends StatefulWidget {
  final ChatData chatData;
  ChatItemScreen(this.chatData);

  @override
  _ChatItemScreenState createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> {
  DB db;

  // keep track of last fetched message to get messages only after this message
  DocumentSnapshot lastSnapshot;

  TextEditingController _textEditingController;
  ScrollController _scrollController;
  FocusNode _textFieldFocusNode;

  String userId;
  String peerId;
  String groupChatId;

  // for handling media selection
  File _selectedMedia;
  MediaType pickedMediaType;
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
  Message msgToReply;
  bool replied = false;

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

  void onMessageSend(String content, MessageType type,
      {MediaType mediaType, ReplyMessage replyDetails}) async {
    // clear text field
    if (content != '') _textEditingController.clear();
    // create timestamp
    DateTime time = DateTime.now();
    final newMessage = Message(
      content: content,
      fromId: userId,
      toId: peerId,
      sendDate: time,
      timeStamp: time.millisecondsSinceEpoch.toString(),
      isSeen: false,
      type: type,
      mediaType: mediaType,
      mediaUrl: null,
      uploadFinished: false,
      reply: replyDetails,
    );

    // add message to messages list
    widget.chatData.messages.insert(0, newMessage);

    // set media message
    if (type == MessageType.Media) mediaMsg = newMessage;

    // add message to database only if its text message
    // media message should be added after uploading and getting its media url
    if (type == MessageType.Text) {
      db.addNewMessage(
        groupChatId,
        time,
        Message.toMap(newMessage),
      );
    }

    final userContacts = Provider.of<Chat>(context, listen: false).getContacts;
    // add user to contacts if not already in contacts
    if (!userContacts.contains(peerId)) {
      Provider.of<Chat>(context, listen: false).addToContacts(peerId);
      db.updateContacts(userId, userContacts);

      // add to peer contacts too
      var userRef = await db.addToPeerContacts(peerId, userId);

      User person = User.fromJson(userRef.data);
      ChatData initChatData = ChatData(
        userId: userId,
        peerId: peerId,
        groupId: groupChatId,
        peer: person,
        messages: [newMessage],
      );
      Provider.of<Chat>(context, listen: false).addToInitChats(initChatData);
    } else {
      Provider.of<Chat>(context, listen: false).bringChatToTop(groupChatId);
    }
  }

  void _onUploadFinished(String url) {
    if (mediaMsg != null) {
      var msg = widget.chatData.messages.firstWhere(
        (elem) => elem.sendDate == mediaMsg.sendDate,
      );

      //
      if (msg != null) {
        msg.mediaUrl = url;
        msg.uploadFinished = true;

        final time = DateTime.now();

        // add message to database after grabbing it's media url
        db.addNewMessage(
          groupChatId,
          time,
          Message.toMap(msg),
        );
        db.addMediaUrl(groupChatId, url, mediaMsg);
      }
    }
  }

  void onReplied(Message msg) async {
    _textFieldFocusNode.requestFocus();
    msgToReply = msg;
    replied = true;
    // if (isVisible) {
      // update input field state to show reply preview
      textFieldKey.currentState.setState(() {});
    // }
  }

  void onSend(String msgContent,
      {MessageType type, MediaType mediaType, ReplyMessage replyDetails}) {
    // if not media is not selected add new message as text message
    if (type == MessageType.Text) {
      if (msgContent.isEmpty) return;
      _textEditingController.clear();
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      // send new message
      onMessageSend(msgContent, MessageType.Text, replyDetails: replyDetails);
    } else {
      if (msgContent.trim().isEmpty) msgContent = null;
      onMessageSend(msgContent, MessageType.Media,
          mediaType: mediaType, replyDetails: replyDetails);
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
          newMsg.sendDate.isAfter(widget.chatData.messages[index].sendDate);

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
          Message newMsg = Message.fromMap(snapshot.data);
          if (widget.chatData.messages.isNotEmpty) {
            // add message to the list only if it's after the first item in the list
            if (newMsg.sendDate.isAfter(widget.chatData.messages[0].sendDate)) {
              widget.chatData.messages.insert(0, newMsg);

              // // play notification sound
              // Utils.playSound('mp3/newMessage.mp3');

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

  Future pickImage() async {
    var pickedFile = await Utils.pickImage(context);
    if (pickedFile != null) {
      setState(() {
        pickedMediaType = MediaType.Photo;
        _selectedMedia = File(pickedFile.path);
        _mediaSelected = true;
      });
    }
  }

  Future pickVideo() async {
    var pickedFile = await Utils.pickVideo(context);
    if (pickedFile != null) {
      setState(() {
        pickedMediaType = MediaType.Video;
        _selectedMedia = File(pickedFile.path);
        _mediaSelected = true;
      });
    }
  }

  Widget _buildTextInputField() {
    return StatefulBuilder(
      key: textFieldKey,
      builder: (ctx, thisState) {
        bool reply = false;
        Message repliedMessage;

        // update state when message is being replied
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
            if (repliedMessage.type == MessageType.Text)
              replyDetails.content = repliedMessage.content;
            else
              replyDetails.content = repliedMessage.mediaUrl;
            replyDetails.type = repliedMessage?.type;
          }
          onSend(_textEditingController.text,
              type: MessageType.Text, replyDetails: replyDetails);

          // reset state
          thisState(() {
            reply = false;
            repliedMessage = null;
          });
        }

        Widget _buildTextField() {
          return Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 5),
              decoration: BoxDecoration(
                  color: kBlackColor2, borderRadius: BorderRadius.circular(25)),
              child: TextField(
                maxLines: null,
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
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                onSubmitted: (_) => send(),
              ),
            ),
          );
        }

        Widget _buildReplyMessage() {
          return AnimatedContainer(
            padding: const EdgeInsets.only(left: 20),
            duration: Duration(milliseconds: 200),
            height: reply ? 70 : 0,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: reply
                    ? BorderSide(color: kBorderColor3)
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
                    peerName: widget.chatData.peer.username,
                    reply: reply,
                    userId: userId,
                  )
                : Container(width: 0, height: 0),
          );
        }

        return Container(
          decoration: BoxDecoration(
            // color: kBlackColor2,
            // border: Border.all(color: kBorderColor3),
            borderRadius: reply
                ? BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  )
                : BorderRadius.circular(25),
          ),
          // borderRadius: BorderRadius.circular(25)),
          child: Column(
            children: [
              _buildReplyMessage(),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // SizedBox(width: 5),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: Icon(
                          Icons.image,
                          size: 20,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: () => pickImage(),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: Icon(
                        Icons.videocam,
                        size: 25,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () => pickVideo(),
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
              ),
            ],
          ),
        );
      },
    );
  }

  // Fetch chats on scroll
  bool _onNotification(Notification notification) {
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
    // FlutterStatusbarcolor.setStatusBarColor(kBlackColor2);
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    return SafeArea(
      bottom: false,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: _mediaSelected
              ? Size.fromHeight(0)
              : Size.fromHeight(kToolbarHeight),
          child: MyAppBar(widget.chatData.peer, widget.chatData.groupId),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(bodyFocusNode);
          },
          child: Container(
            color: kBlackColor,
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
                            Flexible(
                              child: _Messages(
                                scrollController: _scrollController,
                                chatData: widget.chatData,
                                onNotification: _onNotification,
                                selectedMedia: _selectedMedia,
                                onReplied: onReplied,
                                onUploadFinished: _onUploadFinished,
                              ),
                            ),
                            _buildTextInputField(),
                          ],
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  bottom: 150,
                  child: _ToBottom(controller: _scrollController),
                ),
                if (_mediaSelected)
                  SelectedMediaPreview(
                    file: _selectedMedia,
                    onClosed: () => setState(() => _mediaSelected = false),
                    onSend: onSend,
                    textEditingController: _textEditingController,
                    pickedMediaType: pickedMediaType,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToBottom extends StatefulWidget {
  final ScrollController controller;
  const _ToBottom({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  __ToBottomState createState() => __ToBottomState();
}

class __ToBottomState extends State<_ToBottom> {
  bool reachedThereshold = false;

  @override
  void initState() {
    super.initState();
    
    widget.controller.addListener(() {
      if (widget.controller.position.pixels >= 600) {
        if (!reachedThereshold) {
          setState(() {
            reachedThereshold = true;
          });
        }
      }
      if (widget.controller.position.pixels < 600) {
        if (reachedThereshold) {
          setState(() {
            reachedThereshold = false;
          });
        }
      }
    });
  }

  void onTap() {
    widget.controller.animateTo(widget.controller.position.minScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Widget _buildIcon() {    
    return Container(
      width: 70,
      height: 50,
      decoration: BoxDecoration(
        color: kBlackColor3,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: CupertinoButton(
        color: Colors.transparent,
        padding: const EdgeInsets.all(0),
        onPressed: onTap,
        child: Container(
          child: Icon(Icons.arrow_drop_down_outlined,
              size: 20, color: Theme.of(context).accentColor),
          // padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).accentColor, width: 1.5),
              borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return reachedThereshold ? _buildIcon() : Container(height: 0, width: 0);
  }
}

class _Messages extends StatelessWidget {
  final ScrollController scrollController;
  final ChatData chatData;
  final Function onNotification;
  final File selectedMedia;
  final Function onUploadFinished;
  final Function onReplied;

  const _Messages({
    Key key,
    @required ScrollController scrollController,
    @required this.chatData,
    @required this.onNotification,
    @required this.selectedMedia,
    @required this.onUploadFinished,
    @required this.onReplied,
  })  : scrollController = scrollController,
        super(key: key);

  Widget _buildMessageItem(Message message, bool withoutAvatar, bool last,
      bool first, bool isMiddle) {
    if (message.type == MessageType.Media) {
      if (message.mediaUrl == null || !message.uploadFinished)
        return MediaUploadingBubble(
          groupId: chatData.groupId,
          file: selectedMedia,
          time: message.sendDate,
          onUploadFinished: onUploadFinished,
          message: message,
          mediaType: message.mediaType,
        );
      else
        return ChatBubble(
          message: message,
          isMe: message.fromId == chatData.userId,
          peer: chatData.peer,
          withoutAvatar: withoutAvatar,
          onReply: onReplied,
        );
    }
    return ChatBubble(
      message: message,
      isMe: message.fromId == chatData.userId,
      peer: chatData.peer,
      withoutAvatar: withoutAvatar,
      onReply: onReplied,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: onNotification,
      child: ListView.separated(
        addAutomaticKeepAlives: true,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        reverse: true,
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        itemCount: chatData.messages.length,
        itemBuilder: (ctx, i) {
          int length = chatData.messages.length;
          return _buildMessageItem(
              chatData.messages[i],
              ChatOps.withoutAvatar(
                  i, length, chatData.messages, chatData.peerId),
              ChatOps.isLast(i, length, chatData.messages),
              ChatOps.isFirst(i, length, chatData.messages),
              ChatOps.isMiddle(i, length, chatData.messages));
        },
        separatorBuilder: (_, i) {
          final msgs = chatData.messages;
          int length = msgs.length;
          if ((i != length && msgs[i].fromId != msgs[i + 1].fromId) ||
              msgs[i].reply != null) return SizedBox(height: 15);
          return SizedBox(height: 5);
        },
      ),
    );
  }
}

class ChatOps {
  // show peer avatar only once in a series of nessages
  static bool withoutAvatar(
      int i, int length, List<dynamic> messages, String peerId) {
    bool c1 = i != 0 && messages[i - 1].fromId == peerId;
    bool c2 = i != 0 && messages[i - 1].type != MessageType.Media;
    return c1 && c2;
  }

  // for adding border radius to all sides except for bottomRight/bottomLeft
  // if last message in a series from same user
  static bool isLast(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId == messages[i].fromId;
    bool c2 = i != 0 && messages[i - 1].type != MessageType.Media;
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
