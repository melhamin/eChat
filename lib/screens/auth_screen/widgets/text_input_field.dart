import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../consts.dart';


class TextInputField extends StatelessWidget {
  const TextInputField({
    Key key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onSaved,
    this.validator,
    this.obscureText = false,
  }) : super(key: key);

  final FocusNode focusNode;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Function onSaved;
  final Function validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.transparent),
        color: kBlackColor3,
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: kBaseWhiteColor,
        ),
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle:
              TextStyle(color: kBaseWhiteColor.withOpacity(0.6), fontSize: 16),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
