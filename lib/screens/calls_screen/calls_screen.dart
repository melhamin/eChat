import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/screens/calls_screen/widgets/call_item.dart';
import 'package:whatsapp_clone/widgets/body_list.dart';
import 'package:whatsapp_clone/widgets/tab_title.dart';

class CallsScreen extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    // FlutterStatusbarcolor.setStatusBarColor(kBlackColor);
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    return Column(
      children: [
        TabScreenTitle(
          title: 'Calls',
          actionWidget: CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Icon(Icons.more_vert, color: Colors.white, size: 25),
              decoration: BoxDecoration(
                color: kBlackColor3,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          onTap: () {},
        ),      
        BodyList(
          child: ListView.separated(
            itemCount: 6,
            itemBuilder: (_, i) => CallItem(),

            separatorBuilder: (_, i) => Divider(
              indent: 72,
              endIndent: 15,
              height: 0,
              color: kBorderColor3,
            ),
          ),
        )       
      ],
    );
  }
}
