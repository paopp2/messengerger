import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerger/screens/chat_list_screen.dart';
import 'package:messengerger/screens/people_list_screen.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({
    Key key,
    @required this.user,
    @required this.selectedIndex,
    @required this.onTap
  }) : super(key: key);

  final FirebaseUser user;
  final int selectedIndex;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text('Chats'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          title: Text('People'),
        ),
      ],
      onTap: onTap,
    );
  }
}