import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:whatsapp_clone/screens/calls_screen/widgets/call.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
import 'package:whatsapp_clone/widgets/toast_utils.dart';

class CallItem extends StatelessWidget {
  void call(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Call(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: kBlackColor,
        splashColor: Colors.transparent,
        onTap: () => ToastUtils.myToastMessage(
          context: context,
          alignment: Alignment.topCenter,
          child: Call(),
          duration: Duration(seconds: 5),
        ),
        child: ListTile(
          leading: Avatar(imageUrl: myPic, radius: 20),
          title: Text('Username'),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                color: kBaseWhiteColor.withOpacity(0.5),
                size: 15,
              ),
              SizedBox(width: 5),
              Text(
                'Incoming',
                style: TextStyle(color: kBaseWhiteColor.withOpacity(0.5)),
              )
            ],
          ),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                DateFormat.Hm().format(DateTime.now()),
                style: TextStyle(color: kBaseWhiteColor.withOpacity(0.65)),
              ),
              SizedBox(width: 8),
              Icon(Icons.info_outline, color: Theme.of(context).accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
