import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messengerger/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
            otherUserData['username'],
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
                      onPressed: () async {
                        messageTextController.clear();
                        String user1 = thisUser.email;
                        String user2 = otherUserData['email'] ?? otherUserData['receiver'];
                        String roomName = (user1.compareTo(user2) < 0) ? user1+'_'+user2 : user2+'_'+user1;
                        String user2Username = otherUserData['username'];
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
                        _firestore.collection('users')
                            .document(user1)
                            .collection('chat_rooms')
                            .document(roomName)
                            .setData(
                          {
                            'sender' : thisUser.email,
                            'receiver' : user2,
                            'username' : user2Username,
                            'last_message' : messageText,
                            'timestamp' : Timestamp.now(),
                          }
                        );

                        void addToOtherChatRoom() async {
                          DocumentSnapshot result = await _firestore.collection('users').document(user1).get();
                          _firestore.collection('users')
                              .document(user2)
                              .collection('chat_rooms')
                              .document(roomName)
                              .setData(
                            {
                              'sender' : thisUser.email,
                              'receiver' : user1,
                              'username' : result.data['username'],
                              'last_message' : messageText,
                              'timestamp' : Timestamp.now(),
                            }
                          );
                        }
                        addToOtherChatRoom();
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

    //if pushed from people_list_screen user, get 'email'
    //else if pushed from chat_list_screen, get 'receiver'
    String user2 = otherUserData['email'] ?? otherUserData['receiver'];
    String roomName = (user1.compareTo(user2) < 0) ? user1+'_'+user2 : user2+'_'+user1;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chat_rooms')
          .document(roomName)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: SpinKitRing(
              color: Colors.blue,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'] ?? message.data['last_message'];
          final messageSender = message.data['sender'];
          final currentUser = thisUser.email;
          final tempTimeStamp = message.data['timestamp'];
          final DateTime timeSent = DateTime.parse(tempTimeStamp.toDate().toString());
          final formattedTimeSent = DateFormat.jm().format(timeSent);

          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
            time: formattedTimeSent,
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
  MessageBubble({this.sender, this.text, this.isMe, this.time});

  final String sender;
  final String text;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: (isMe) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
