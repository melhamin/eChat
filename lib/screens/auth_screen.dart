import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/widgets/app_bar.dart';

enum AuthMode {
  SignIn,
  SignUp,
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> _formKey;
  AuthMode authMode = AuthMode.SignIn;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  Widget _buildFormField(String label, String saveTo, Function validator,
          [bool obscureText = false]) =>
      Container(
        height: 55,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.transparent),
          color: Hexcolor('#303030'),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextFormField(
          style: TextStyle(
            fontSize: 16,
            color: kBaseWhiteColor,
          ),
          obscureText: obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            hintStyle:
                TextStyle(color: kBaseWhiteColor.withOpacity(0.6), fontSize: 16),
          ),
          onSaved: (value) => _authData['$saveTo'] = value.trim(),
          validator: validator, 
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Hexcolor('#121212'),
        body: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    authMode == AuthMode.SignIn ? 'Log In' : 'Sign Up',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kBaseWhiteColor),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      authMode == AuthMode.SignIn ? 'Sign Up' : 'Log In',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () => setState(() {
                      if (authMode == AuthMode.SignIn)
                        authMode = AuthMode.SignUp;
                      else
                        authMode = AuthMode.SignIn;
                    }),
                  ),
                ],
              ),
            ),
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
                child: Column(
                  children: [
                    SizedBox(height: 30),
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
                                  'username', (value) {}),
                            ),
                          _buildFormField(
                            'Email',
                            'email',
                            (value){
                              if(value.isEmpty) 
                              return 'Invalid email.';
                              return null;
                            }
                          ),
                          _buildFormField(
                            'Password',
                            'password',
                            (value){
                              if(value.isEmpty) 
                              return 'Invalid password.';
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
                        onPressed: () => authMode == AuthMode.SignUp
                            ? _signUp()
                            : _signIn()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    Provider.of<Auth>(context, listen: false)
        .signUp(_authData['username'], _authData['email'], _authData['password']);
  }

  void _signIn() {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    print('sign in calle ------------>');
    Provider.of<Auth>(context, listen: false)
        .signIn(_authData['email'], _authData['password']);
  }
}
