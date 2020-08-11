import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/calls_screen.dart';
import 'package:whatsapp_clone/screens/chats_screen/chats_screen.dart';
import 'package:whatsapp_clone/screens/contacts_screen.dart';
import 'package:whatsapp_clone/screens/profile_info.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin, WidgetsBindingObserver  {
  TabController tabController;
  DB db;
  bool isLoading = true;
  bool initLoaded = false;

  AppLifecycleState _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    db = DB();    
    // Fetch user data(chats and contacts), and update online status
    Future.delayed(Duration.zero).then((value) {         
        Provider.of<User>(context, listen: false).getUserDetailsAndContacts().then((value) {
          if(value)
          Provider.of<User>(context, listen: false).fetchChats();
          _updateOnlineStatus(true);          
        });        
      }).then((value) => setState(() => initLoaded = true));    
  }

  @override
  void didChangeDependencies() {    
    if (initLoaded) {
      setState(() {
        isLoading = false;
        initLoaded = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {  
    if(state == AppLifecycleState.paused)  _updateOnlineStatus(false);
    else if(state == AppLifecycleState.resumed) _updateOnlineStatus(true);
    // else if(state == AppLifecycleState.detached) _updateOnlineStatus(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Update user status on Firebase
  Future<dynamic> _updateOnlineStatus(bool status) {
    final uid = Provider.of<User>(context, listen: false).getUserId;
    final docRef = Firestore.instance.collection(USERS_COLLECTION).document(uid);
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

  void updateChats(AsyncSnapshot<dynamic> snapshots) {
    final currContacts = Provider.of<User>(context).getContacts;
    final currContactLength = currContacts.length;
    if (snapshots.data != null && snapshots.hasData) {
      if (snapshots.data != null) {
        final contacts = snapshots.data['contacts'];        
        if (contacts.length > currContactLength) {          
          Provider.of<User>(context, listen: false)
              .handleMessagesNotFromContacts(contacts);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {    
    final uid = Provider.of<User>(context).getUserId;    
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: db.getUserContactsStream(uid),
          builder: (ctx, snapshots) {
            if (!isLoading) updateChats(snapshots);
            return _buildTabContent();
          },
        ),
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

    BottomNavigationBarItem _buildTabBarItem(String label, IconData icon, IconData activeIcon) {
      return BottomNavigationBarItem(
        icon: Icon(icon),
        activeIcon: Icon(activeIcon, size: 35),
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(label, style: labelStyle),
        ),
      );
    }

    return CupertinoTabBar(
      items: [
        _buildTabBarItem('Calls', CupertinoIcons.phone, CupertinoIcons.phone_solid),
        _buildTabBarItem('Chats', CupertinoIcons.conversation_bubble, CupertinoIcons.conversation_bubble),
        _buildTabBarItem('Contacts', CupertinoIcons.group,CupertinoIcons.group_solid),
        _buildTabBarItem('Me', CupertinoIcons.person, CupertinoIcons.person_solid),
      ],
      onTap: onTap,
      currentIndex: currentIndex,
      activeColor: Theme.of(context).accentColor,
      inactiveColor: Colors.white.withOpacity(0.7),
      backgroundColor: Hexcolor('#121212'),
    );
  }
}
