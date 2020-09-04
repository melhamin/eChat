import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/services/db.dart';

abstract class BaseAuth {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String username, String email, String password);
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
  Future<bool> signIn(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      _fbUser = user;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  @override
  Future<bool> signUp(String username, String email, String password) async {
    // print('email ======> $email password ----------> $password');
    try {
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
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  @override
  Future<void> signOut() {
    var res = _firebaseAuth.signOut();
    notifyListeners();
    return res;
  }
}
