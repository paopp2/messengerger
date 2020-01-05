import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerger/screens/chat_screen.dart';
import 'package:messengerger/screens/all_people_list_screen.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({
    Key key,
    @required this.user,
  }) : super(key: key);

  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      onTap: (index) {
        switch(index) {
          case 0: {
            Navigator.pushNamed(context, ChatScreen.id);
          }
          break;
          case 1: {
            Navigator.pushNamed(context, AllPeopleListScreen.id, arguments: user);
          }
        }
      },
    );
  }
}