import 'package:flutter/material.dart';
import 'package:messengerger/components/my_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messengerger/screens/chat_screen.dart';
import 'people_list_screen.dart';


final _fireAuth = FirebaseAuth.instance;
final _firestore = Firestore.instance;
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
    getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ChatsStream(
        currentUserEmail: (user != null) ? user.email : '?',
      ),
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

class ChatListTile extends StatelessWidget {
  ChatListTile({this.onTilePressed, this.lastMessage, this.sender, this.receiver, this.receiverUsername});

  final Function onTilePressed;
  final String receiver;
  final String receiverUsername;
  final String sender;
  final String lastMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        onPressed: onTilePressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.chat_bubble_outline,
                size: 40,
              ),
              SizedBox(width: 15,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    receiverUsername,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$sender: $lastMessage',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatsStream extends StatelessWidget {
  ChatsStream({this.currentUserEmail});

  final String currentUserEmail;

  @override
  Widget build(BuildContext context) {
    var userChatRoomsRef = _firestore.collection('users').document(currentUserEmail).collection('chat_rooms');
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: (currentUserEmail != null) ? userChatRoomsRef.snapshots() : null,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(
              child: SpinKitRing(
                color: Colors.blue,
              ),
            );
          }
          List<ChatListTile> chatListTiles = [];
          final chatLists = snapshot.data.documents;
          for (var chat in chatLists) {
            final receiver = chat.data['receiver'];
            final receiverUsername = chat.data['username'];
            final sender = chat.data['sender'];
            final lastMessage = chat.data['last_message'];
            var chatListTile = ChatListTile(
              receiver: receiver,
              receiverUsername : receiverUsername,
              sender: (currentUserEmail == sender) ? 'You' : receiverUsername,
              lastMessage: lastMessage,
              onTilePressed: () {
                Navigator.pushNamed(
                  context,
                  ChatScreen.id,
                  arguments: chat.data,
                );
              },
            );
            chatListTiles.add(chatListTile);
          }
          return ListView.builder(
            itemCount: chatListTiles.length,
            itemBuilder: (context, index) {
              return chatListTiles[index];
            },
          );
        },
      ),
    );
  }
}


