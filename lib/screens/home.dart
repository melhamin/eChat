import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
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
      Provider.of<User>(context, listen: false).getUserData();
    });
  }

  Widget _buildTabs() {
    return TabBar(
      labelStyle: kSelectedTabStyle,
      unselectedLabelStyle: kUnselectedTabStyle,
      controller: tabController,
      labelColor: Colors.white,
      indicatorColor: Colors.white.withOpacity(0.87),
      indicatorWeight: 3,
      tabs: [
        Tab(
          child: Text('CALLS'),
        ),
        Tab(
          child: Text('CHATS'),
        ),
        Tab(
          child: Text('CONTACTS'),
        ),
      ],
    );
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(            
            title: Text('WhatsApp', style: kWhatsAppStyle),
            bottom: _buildTabs(),
            actions: [
              IconButton(icon: Icon(Icons.search),  onPressed: () {
                Provider.of<Auth>(context, listen: false).signOut();
              },),
              IconButton(icon: Icon(Icons.message),  onPressed: () {                
              },),
              IconButton(icon: Icon(Icons.more_vert),  onPressed: () {},)
            ],
          ),
        ),
        body: _buildTabContent(),
      ),
    );
  }
}
