import 'package:flutter/material.dart';
import 'package:messengerger/components/my_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'people_list_screen.dart';


final _fireAuth = FirebaseAuth.instance;
int index = 0;

class ChatListScreen extends StatefulWidget {
  static const id = 'chat_list_screen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  FirebaseUser user;
  void getCurrentUser() async{
    var tempUser = await _fireAuth.currentUser();
    setState(() {
      user = tempUser;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      bottomNavigationBar: MyBottomNavigationBar(
        user: user,
        selectedIndex: index,
        onTap: (index) {
          switch(index) {
            case 0: {
              Navigator.pushNamed(context, ChatListScreen.id);
            }
            break;
            case 1: {
              Navigator.pushNamed(context, PeopleListScreen.id, arguments: user);
            }
            break;
          }
        },
      ),
    );
  }
}
