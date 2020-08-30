import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/screens/auth_screen/widgets/text_input_field.dart';
import 'package:whatsapp_clone/screens/auth_screen/widgets/toggle_auth_mode.dart';

import '../../../consts.dart';

enum AuthMode {
  SignIn,
  SignUp,
}

class InputSection extends StatefulWidget {
  InputSection({
    Key key,
  }) : super(key: key);

  @override
  _InputSectionState createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  GlobalKey<FormState> _formKey;
  AuthMode authMode = AuthMode.SignIn;
  TextEditingController textEditingController;
  FocusNode _usernameFocus;
  FocusNode _emailFocus;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _usernameFocus = FocusNode();
    _emailFocus = FocusNode();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Widget _buildFormField(String hintText, String saveTo, Function validator,
      [bool obscureText = false,
      TextEditingController controller,
      FocusNode focusNode]) {
    return TextInputField(
        hintText: hintText,
        onSaved: (value) => _authData['$saveTo'] = value.trim(),
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        validator: validator);
  }

  void _toggleAuthMode() {
    setState(() {
      if (authMode == AuthMode.SignIn) {
        authMode = AuthMode.SignUp;
        _usernameFocus.requestFocus();
      } else {
        authMode = AuthMode.SignIn;
        textEditingController.text = '';
        _emailFocus.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ListView(
      children: [
        // SizedBox(height: 30),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // if (authMode == AuthMode.SignUp)
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: authMode == AuthMode.SignUp ? 75 : 0,
                child: _buildFormField(
                    authMode == AuthMode.SignUp ? 'Username' : '',
                    'username',
                    (value) {},
                    false,
                    textEditingController,
                    _usernameFocus),
              ),
              _buildFormField('Email', 'email', (value) {
                if (value.isEmpty) return 'Invalid email.';
                return null;
              }, false, null, _emailFocus),
              _buildFormField(
                'Password',
                'password',
                (value) {
                  if (value.isEmpty) return 'Invalid password.';
                  return null;
                },
                true,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        CupertinoButton(
          child: Container(
            width: mq.size.width * 0.5,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              authMode == AuthMode.SignIn ? 'Log In' : 'Sign Up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kBaseWhiteColor,
              ),
            ),
          ),
          onPressed: () => authMode == AuthMode.SignUp ? _signUp() : _signIn(),
        ),
        ToggleAuthMode(authMode: authMode, toggle: _toggleAuthMode),
      ],
    );
  }

  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
  };

  void _signUp() {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    print('singup calle ------------>');
    Provider.of<Auth>(context, listen: false).signUp(
        _authData['username'], _authData['email'], _authData['password']);
  }

  void _signIn() {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    print('sign in calle ------------>');
    Provider.of<Auth>(context, listen: false)
        .signIn(_authData['email'], _authData['password']);
  }
}
