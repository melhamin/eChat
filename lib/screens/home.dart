import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/all_users.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/calls_screen.dart';
import 'package:whatsapp_clone/screens/chats_screen.dart';
import 'package:whatsapp_clone/screens/contacts_screen.dart';
import 'package:whatsapp_clone/screens/profile_info.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);

    // Fetch user data(chats and contacts), and update online status
    Future.delayed(Duration.zero).then((value) {
      Provider.of<AllUsers>(context, listen: false).fetchAllUsers();
      Provider.of<User>(context, listen: false).getUserData().then((value) {
        Provider.of<User>(context, listen: false).fetchChats();
        _updateOnlineStatus(true);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _updateOnlineStatus(false).then((value) => super.dispose());
    // super.dispose();
  }

  /// Update user status on Firebase
  Future<dynamic> _updateOnlineStatus(bool status) {
    final uid = Provider.of<User>(context, listen: false).getUserId;
    final docRef = Firestore.instance.collection('users').document(uid);
    return Firestore.instance.runTransaction((transaction) async {
      await transaction.update(docRef, {
        'isOnline': status,
      });
    });
  }

  Widget _buildTabs() {
    return Container(
      color: Hexcolor('#121212'),
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Tabs(tabController),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: tabController,
      children: [
        CallsScreen(),
        ChatsScreen(),
        ContactsScreen(),
        ProfileInfo(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildTabContent(),
        bottomNavigationBar: _buildTabs(),
      ),
    );
  }
}

class Tabs extends StatefulWidget {
  final TabController tabController;
  Tabs(this.tabController);
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int currentIndex = 0;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
    widget.tabController.index = index;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    BottomNavigationBarItem _buildTabBarItem(String label, IconData icon) {
      return BottomNavigationBarItem(
        icon: Icon(icon),
        title: Text(label, style: labelStyle),
      );
    }

    return CupertinoTabBar(
      items: [
        _buildTabBarItem('Calls', Icons.call),
        _buildTabBarItem('Chats', Icons.message),
        _buildTabBarItem('Contacts', Icons.contact_phone),
        _buildTabBarItem('Me', Icons.person),
      ],
      onTap: onTap,
      currentIndex: currentIndex,
      activeColor: Theme.of(context).accentColor,
      inactiveColor: Colors.white.withOpacity(0.7),
      backgroundColor: Hexcolor('#121212'),
    );
  }
}
