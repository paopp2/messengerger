import 'package:flutter/material.dart';
import 'package:messengerger/components/my_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _fireAuth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
      bottomNavigationBar: MyBottomNavigationBar(user: user,),
    );
  }
}
