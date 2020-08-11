import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/screens/auth_screen/widgets/input_section.dart';

import '../../../consts.dart';


class ToggleAuthMode extends StatelessWidget {
  const ToggleAuthMode({    
    Key key,
    @required this.authMode,
    @required this.toggle,
  }) : super(key: key);

  final AuthMode authMode;
  final Function toggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          authMode == AuthMode.SignIn
              ? 'Don\'t have an account?'
              : 'Already have an account?',
          style: TextStyle(
            color: kBaseWhiteColor.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        SizedBox(width: 10),
        CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: Text(
            authMode == AuthMode.SignIn ? 'Sign Up' : 'Sign In',
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: toggle,
        ),
      ],
    );
  }
}
