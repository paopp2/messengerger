import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messengerger/constants.dart';

final _fireAuth = FirebaseAuth.instance;
final _firestore = Firestore.instance;
FirebaseUser thisUser;
Map<String, dynamic> otherUserData;

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = new TextEditingController();
  String messageText;

  void getUsersInRoom() async{
    var tempUser = await _fireAuth.currentUser();
    var tempOtherUserData = ModalRoute.of(context).settings.arguments;
    setState(() {
      thisUser = tempUser;
      otherUserData = tempOtherUserData;
    });
  }

  @override
  Widget build(BuildContext context) {
    getUsersInRoom();
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _fireAuth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text(
            (otherUserData != null) ? otherUserData['username'] : 'Something else',
            style: TextStyle(
              fontSize: 25,
            ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        style: TextStyle(
                            color: Colors.black
                        ),
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        messageTextController.clear();
                        String user1 = thisUser.email;
                        String user2 = otherUserData['email'];
                        String roomName = (user1.compareTo(user2) < 0) ? user1+'_'+user2 : user2+'_'+user1;
                        _firestore.collection('chat_rooms')
                            .document(roomName)
                            .collection('messages')
                            .add(
                                {
                                  'text' : messageText,
                                  'sender' : thisUser.email,
                                  'timestamp' : Timestamp.now(),
                                }
                        );
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String user1 = thisUser.email;
    String user2 = otherUserData['email'];
    String roomName = (user1.compareTo(user2) < 0) ? user1+'_'+user2 : user2+'_'+user1;
    return StreamBuilder<QuerySnapshot>(
//      stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
      stream: _firestore.collection('chat_rooms')
          .document(roomName)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return CircularProgressIndicator(
            backgroundColor: Colors.blue,
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final currentUser = thisUser.email;

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: messageBubbles.length,
            itemBuilder: (context, index) {
              return messageBubbles[index];
            },
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: (isMe) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
//          Text(
//            sender,
//            style: TextStyle(
//              fontSize: 12,
//              color: Colors.black54,
//            ),
//          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
              topLeft: (isMe) ? Radius.circular(30) : Radius.zero,
              topRight: (isMe) ? Radius.zero : Radius.circular(30),
            ),
            color: (isMe) ? Colors.lightBlueAccent: Colors.grey[350],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
