import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/providers/auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Hexcolor('#121212'),
      body: Center(
        child: Container(
          color: Colors.white.withOpacity(0.9),
          height: 500,
          width: double.infinity,
          child: Column(
            children: [
              Text(
                authMode == AuthMode.SignIn ? 'Sign In' : 'Sign Up',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if(authMode == AuthMode.SignUp)
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.black,
                      )),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        onSaved: (value) => _authData['username'] = value.trim(),
                        validator: (val) {
                          if(val.isEmpty) return 'Please enter a username';
                          return null;
                        },
                      ),                      
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.black,
                      )),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        onSaved: (value) => _authData['email'] = value.trim(),
                        validator: (val) {
                          if(val.isEmpty) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.black,
                      )),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(                          
                          hintText: 'Password',
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        onSaved: (value) => _authData['password'] = value.trim(),
                        validator: (val) {
                          if(val.isEmpty) return 'Please enter a valid password';
                          return null;
                        },
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                          color: Hexcolor('#075E54'),
                          child: Text(
                            authMode == AuthMode.SignIn ? 'Login' : 'Sign Up',
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          onPressed: () => authMode == AuthMode.SignIn ? _signIn() : _signUp(),
                        ),
                        RaisedButton(
                          child: Text(
                            authMode == AuthMode.SignIn ? 'Create Account': 'Have account? login',
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          onPressed: () {                            
                            setState(() {
                              if(authMode == AuthMode.SignIn)                              
                              authMode = AuthMode.SignUp;
                              else 
                              authMode = AuthMode.SignIn;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    if(!_formKey.currentState.validate()) return; 
    _formKey.currentState.save();   
    Provider.of<Auth>(context, listen: false).signUp(_authData['email'], _authData['password']);
    
  }
  void _signIn() {
    if(!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    Provider.of<Auth>(context, listen: false).signIn(_authData['email'], _authData['password']);
    
  }
}
