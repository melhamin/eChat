import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/database/db.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String username, String email, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<void> signOut();
}

class Auth with ChangeNotifier implements BaseAuth {  

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static FirebaseUser _user;

  bool get isAuth {
    return _user != null;
  }

  FirebaseUser get getUser {
    return _user;
  }

  void reloadUser() {
    _user.reload();
    notifyListeners();
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    _user = await _firebaseAuth.currentUser();
    return _user;
  }

  @override
  Future<String> signIn(String email, String password) async {    
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    _user = user;
    notifyListeners();
    return user.uid;
  }

  @override
  Future<String> signUp(String username, String email, String password) async {
    // print('email ======> $email password ----------> $password');
    final db = DB();
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    _user = user;

    notifyListeners();

    db.addNewUser(_user.uid, _user.photoUrl, username, email); 
    // ProfileInfo info = ProfileInfo();
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = username;    
    _user.updateProfile(info);
    return user.uid;
  }

  @override
  Future<void> signOut() {
    var res = _firebaseAuth.signOut();    
    notifyListeners();
    return res;
  }
}
