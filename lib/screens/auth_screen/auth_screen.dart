import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/screens/auth_screen/widgets/input_section.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';



class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Hexcolor('#121212'),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              TabScreenTitle(title: 'Welcome'),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Hexcolor('#202020'),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                    ),
                  ),
                  child: InputSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
