import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/person.dart';

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

  List<Map<String, dynamic>> dummyTexts = [
    {
      'text': 'hey whats upp?',
      'isMe': false,
    },
    {
      'text': 'I\'m good dude. how are you?',
      'isMe': true,
    },
    {
      'text': 'Where are you now',
      'isMe': true,
    },
    {
      'text': 'I am fine thanks',
      'isMe': false,
    },
    {
      'text': 'In istanbul. Where are you ?',
      'isMe': false,
    },
    {
      'text': 'Mee too',
      'isMe': true,
    },
    {
      'text': 'Let\'s meet up',
      'isMe': true,
    },
    {
      'text': 'I will come to you tomorrow. good?',
      'isMe': false,
    },
    {
      'text': 'Done',
      'isMe': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundImage:
                    CachedNetworkImageProvider(widget.person.imageUrl),
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
        body: GestureDetector(
          onPanDown: (value) {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              print(constraints.maxWidth);
              return Column(
                children: [
                  Flexible(
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      itemCount: dummyTexts.length,
                      itemBuilder: (ctx, i) {
                        return MessageBubble(
                          text: dummyTexts[i]['text'],
                          isMe: dummyTexts[i]['isMe'],
                        );
                      },
                      separatorBuilder: (_, __) {
                        return SizedBox(height: 10);
                      },
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth,
                    margin:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5)),
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
                                dummyTexts.add({
                                  'text': value,
                                  'isMe': true,
                                });
                                _textEditingController.clear();
                                _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent +
                                        50,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeIn);
                              });
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
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  MessageBubble({
    @required this.text,
    @required this.isMe,
  });

  bool didExceedMaxLines(double maxWidth) {
    final span = TextSpan(text: text);
    final tp =
        TextPainter(text: span, maxLines: 1, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth);
    print('maxwidth' + maxWidth.toString());

    return tp.didExceedMaxLines;
  }

  List<Widget> _buildBubbleContent() {
    return [
      Text(
        text,
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
              '${DateTime.now().hour}:${DateTime.now().minute}',
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
