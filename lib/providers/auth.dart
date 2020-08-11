import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String username, String email, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<void> signOut();
}

class Auth with ChangeNotifier implements BaseAuth {  

  // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseUser _fbUser;  

  bool get isAuth {
    return _fbUser != null;
  }

  FirebaseUser get getUser {
    return _fbUser;
  }

  void reloadUser() {
    _fbUser.reload();
    notifyListeners();
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    _fbUser = await _firebaseAuth.currentUser();    
    return _fbUser;
  }

  @override
  Future<String> signIn(String email, String password) async {    
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    _fbUser = user;
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
    _fbUser = user;

    notifyListeners();

    db.addNewUser(_fbUser.uid, _fbUser.photoUrl, username, email); 
    // ProfileInfo info = ProfileInfo();
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = username;    
    _fbUser.updateProfile(info);
    return user.uid;
  }

  @override
  Future<void> signOut() {
    var res = _firebaseAuth.signOut();    
    notifyListeners();
    return res;
  }
}
