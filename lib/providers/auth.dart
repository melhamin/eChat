import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
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

  static FirebaseUser get getUser {
    return _user;
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
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
  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    _user = user;    

    notifyListeners();
    return user.uid;
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  // String _token;
  // DateTime _expireDate;
  // String _userId;
  // Timer _authTimer;

  // String get token {
  //   if (_expireDate != null &&
  //       _expireDate.isAfter(DateTime.now()) &&
  //       _token != null) return _token;
  //   return null;
  // }

  // bool get isAuth {
  //   return _token != null;
  // }

  // String get userId {
  //   return _userId;
  // }

  // Future<void> authenticate(
  //     String email, String password, String urlSegment) async {
  //   print('email: $email');
  //   print('password: $password');
  //   final url =
  //       'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyC-6MQGM-ilcUBoYhvUXl2aJ84s5bHnWUc ';
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode(
  //         {'email': email, 'password': password, 'returnSecureToken': true},
  //       ),
  //     );
  //     final responseData = json.decode(response.body);

  //     if (responseData['error'] != null) {
  //       throw HttpException(responseData['error']['message']);
  //     }

  //     _token = responseData['idToken'];
  //     _expireDate = DateTime.now()
  //         .add(Duration(seconds: int.parse(responseData['expiresIn'])));

  //     _userId = responseData['localId'];

  //     notifyListeners();

  //     SharedPreferences prefs = await _prefs;
  //     final authData = json.encode({
  //       'token': _token,
  //       'expireDate': _expireDate.toIso8601String(),
  //       'userId': _userId,
  //     });

  //     prefs.setString('authData', authData);

  //     print(response.body);
  //   } catch (error) {
  //     print(error);
  //     throw error;
  //   }
  // }

  // void signUp(String email, String password) {
  //   authenticate(email, password, 'signUp');
  // }

  // void signIn(String email, String password) {
  //   authenticate(email, password, 'signInWithPassword');
  // }

  // Future<bool> tryAutoLogin() async {
  //   final prefs = await _prefs;
  //   if (!prefs.containsKey('authData')) return false;
  //   final extractedData =
  //       json.decode(prefs.getString('authData')) as Map<String, dynamic>;
  //   final expireData = DateTime.parse(extractedData['expireData']);
  //   if (expireData.isBefore(DateTime.now())) return false;
  //   _token = extractedData['token'];
  //   _userId = extractedData['userId'];
  //   _expireDate = expireData;
  //   notifyListeners();
  //   autoLogout();
  //   return true;
  // }

  // Future<void> logout() async {
  //   _token = null;
  //   _userId = null;
  //   _expireDate = null;

  //   if(_authTimer != null) {
  //     _authTimer.cancel();
  //     _authTimer = null;
  //   }
  //   notifyListeners();
  //   final prefs = await _prefs;
  //   prefs.clear();
  // }

  // void autoLogout() {
  //   if(_authTimer != null) {
  //     _authTimer.cancel();
  //   }

  //   final timeToExpire = _expireDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  // }
}
