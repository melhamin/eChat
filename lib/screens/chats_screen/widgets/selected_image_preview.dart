
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../consts.dart';

class SelectedImagePreview extends StatelessWidget {
  final File image;
  final TextEditingController textEditingController;
  final Function onSend;
  final Function onClosed;
  SelectedImagePreview({
    @required this.image,
    @required this.textEditingController,
    @required this.onSend,
    @required this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
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
                    onPressed: onClosed),
              ),
              Container(
                alignment: Alignment.center,
                height: constraints.maxHeight * 0.8 - 35,
                width: double.infinity,
                child: Image.file(image, fit: BoxFit.cover),
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
                        controller: textEditingController,
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
                      onPressed: () => onSend(textEditingController.text),
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
}
