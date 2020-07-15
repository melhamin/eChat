import 'dart:io';

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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    Future.delayed(Duration.zero).then((value) {
      Provider.of<AllUsers>(context, listen: false).fetchAllUsers();
      Provider.of<User>(context, listen: false).getUserData().then((value) {
        Provider.of<User>(context, listen: false).fetchChats();
      });
    });
  }

  Widget _buildTabs() {
    return Container(
      color: Hexcolor('#121212'),
      padding: const EdgeInsets.only(bottom:8.0),
      child: Tabs(tabController),
    );
    //   Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: [
    //       GestureDetector(
    //         onTap: () => tabController.index = 0,
    //         child: Center(
    //             child: Text('CALLS',
    //                 style: tabController.index == 0
    //                     ? kSelectedTabStyle
    //                     : kUnselectedTabStyle)),
    //       ),
    //       GestureDetector(
    //         onTap: () => tabController.index = 1,
    //         child: Center(
    //             child: Text('CHATS',
    //                 style: tabController.index == 1
    //                     ? kSelectedTabStyle
    //                     : kUnselectedTabStyle)),
    //       ),
    //       GestureDetector(
    //         onTap: () => tabController.index = 2,
    //         child: Center(
    //             child: Text('CONTACTS',
    //                 style: tabController.index == 2
    //                     ? kSelectedTabStyle
    //                     : kUnselectedTabStyle)),
    //       ),
    //     ],
    //   ),
    // );
    // return TabBar(
    //   labelStyle: kSelectedTabStyle,
    //   unselectedLabelStyle: kUnselectedTabStyle,
    //   controller: tabController,
    //   labelColor: Colors.black.withOpacity(0.95),
    //   indicatorColor: Colors.black.withOpacity(0.4),
    //   indicatorWeight: 3,
    //   tabs: [
    //     Tab(child: Text('CALLS')),
    //     Tab(child: Text('CHATS')),
    //     Tab(child: Text('CONTACTS')),
    //   ],
    // );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: tabController,
      children: [
        CallsScreen(),
        ChatsScreen(),
        ContactsScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(kToolbarHeight + 20),
        //   child: AppBar(
        //     elevation: 0,
        //     // backgroundColor: Colors.white.withOpacity(0.87),
        //     backgroundColor: Hexcolor('#EFEEF7'),
        //     // centerTitle: true,
        //     title: Text('eChat', style: kWhatsAppStyle),
        //     // bottom: _buildTabs(),
        //     actions: [
        //       IconButton(
        //       icon: Icon(
        //         Icons.search,
        //         color: Colors.black.withOpacity(0.95),
        //       ),
        //       onPressed: () {
        //         Provider.of<Auth>(context, listen: false).signOut();
        //       },
        //     ),
        //     ],
        //   ),
        // ),
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
    return CupertinoTabBar(   

      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.call),
          title: Text('Calls', style: labelStyle,),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          title: Text('Chats', style: labelStyle,),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contact_phone),
          title: Text('Contacts', style: labelStyle,),
        ),
      ],
      onTap: onTap,
      currentIndex: currentIndex,
      activeColor: Theme.of(context).accentColor,
      inactiveColor: Colors.white.withOpacity(0.7),
      backgroundColor: Hexcolor('#121212'),      
    );
    PreferredSize(
      preferredSize: Size.fromWidth(MediaQuery.of(context).size.width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onTap(0),
            child: Center(
                child: Text('CALLS',
                    style: currentIndex == 0
                        ? kSelectedTabStyle
                        : kUnselectedTabStyle)),
          ),
          GestureDetector(
            onTap: () => onTap(1),
            child: Center(
                child: Text('CHATS',
                    style: currentIndex == 1
                        ? kSelectedTabStyle
                        : kUnselectedTabStyle)),
          ),
          GestureDetector(
            onTap: () => onTap(2),
            child: Center(
                child: Text('CONTACTS',
                    style: currentIndex == 2
                        ? kSelectedTabStyle
                        : kUnselectedTabStyle)),
          ),
        ],
      ),
    );
  }
}
