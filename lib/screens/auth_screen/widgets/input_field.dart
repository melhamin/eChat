import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/providers/auth.dart';

import '../../../consts.dart';

enum AuthMode {
  SignIn,
  SignUp,
}

class InputField extends StatefulWidget {
  InputField({
    Key key,
  }) : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
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
    return ListView(
      children: [
        _InputForm(
            formKey: _formKey,
            authMode: authMode,
            authData: _authData,
            textEditingController: textEditingController,
            usernameFocus: _usernameFocus,
            emailFocus: _emailFocus),
        SizedBox(height: 20),
        _SubmitButton(
          onPressed: () => authMode == AuthMode.SignUp ? _signUp() : _signIn(),
          authMode: authMode,
        ),
        _ToggleAuthMode(authMode: authMode, toggle: _toggleAuthMode),
      ],
    );
  }

  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
  };

  void _signUp() async {    
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    // try signup
    final res = await Provider.of<Auth>(context, listen: false).signUp(
      _authData['username'],
      _authData['email'],
      _authData['password'],
    );

    // sign up failed
    if (!res) showAlertDialog();
  }

  void _signIn() async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();    

    // try sign in
    final res = await Provider.of<Auth>(context, listen: false).signIn(
      _authData['email'],
      _authData['password'],
    );

    // sign failed
    if (!res) showAlertDialog();
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (_) => _AuthFailedAlert(),
    );
  }
}

class _InputForm extends StatelessWidget {
  const _InputForm({
    Key key,
    @required GlobalKey<FormState> formKey,
    @required this.authMode,
    @required Map<String, String> authData,
    @required this.textEditingController,
    @required FocusNode usernameFocus,
    @required FocusNode emailFocus,
  })  : _formKey = formKey,
        _authData = authData,
        _usernameFocus = usernameFocus,
        _emailFocus = emailFocus,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final AuthMode authMode;
  final Map<String, String> _authData;
  final TextEditingController textEditingController;
  final FocusNode _usernameFocus;
  final FocusNode _emailFocus;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: authMode == AuthMode.SignUp ? 75 : 0,
            child: _TextField(
              hintText: authMode == AuthMode.SignUp ? 'Username' : '',
              validator: (value) {},
              onSaved: (value) => _authData['username'] = value.trim(),
              controller: textEditingController,
              focusNode: _usernameFocus,
            ),
          ),
          _TextField(
            hintText: 'Email',
            focusNode: _emailFocus,
            onSaved: (value) {
              _authData['email'] = value.trim();
              print('email saved -----> ${_authData['email']}');
            },
            validator: (_) {},
            obscureText: false,
          ),
          _TextField(
            hintText: 'Password',
            onSaved: (value) {              
              _authData['password'] = value.trim();
              print('email saved -----> ${_authData['password']}');
            },
            validator: (_) {},
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class _AuthFailedAlert extends StatelessWidget {
  const _AuthFailedAlert({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBlackColor2,
      title: Text('Error'),
      content: Text('Invalid email or password!'),
      actions: [
        CupertinoButton(
          child: Container(
            width: 120,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kBaseWhiteColor,
              ),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    Key key,
    @required this.authMode,
    this.onPressed,
  }) : super(key: key);

  final AuthMode authMode;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoButton(
      child: Container(
        width: size.width * 0.5,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          authMode == AuthMode.SignIn ? 'Sign In' : 'Sign Up',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kBaseWhiteColor,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
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

class _ToggleAuthMode extends StatelessWidget {
  const _ToggleAuthMode({
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
