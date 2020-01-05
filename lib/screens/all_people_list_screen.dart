import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerger/components/sliver_app_bar_delegate.dart';
import 'package:messengerger/components/my_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messengerger/components/my_bottom_navigation_bar.dart';

final _firestore = Firestore.instance;
final _fireAuth = FirebaseAuth.instance;
bool isFriends = true;

void showAddedToFriendsSnackBar(String username, BuildContext context) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text('$username added to friends'),
    duration: Duration(milliseconds: 500),
  ));
}

class AllPeopleListScreen extends StatefulWidget {
  static const id = 'all_people_list_screen';
  @override
  _AllPeopleListScreenState createState() => _AllPeopleListScreenState();
}

class _AllPeopleListScreenState extends State<AllPeopleListScreen> {
  FirebaseUser user;

  void getCurrentUser() async{
    var tempUser = await _fireAuth.currentUser();
    if(tempUser == null) {
      tempUser = ModalRoute.of(context).settings.arguments;
    }
    setState(() {
      user = tempUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: null,
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              MySliverAppBar(),
              SliverPersistentHeader(
                delegate: SliverAppBarDelegate(
                  TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.people), text: "Friends"),
                      Tab(icon: Icon(Icons.people_outline), text: "All People"),
                    ],
                    onTap: (index) {
                      setState(() {
                        if(index == 0) {
                          isFriends = true;
                        } else {
                          isFriends = false;
                        }
                      });
                    },
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: UsersStream(
            currentUserEmail: (user != null) ? user.email : '?',
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(user: user),
    );
  }
}

class myDefaultTabController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class PersonListTile extends StatelessWidget {
  PersonListTile({this.username, this.email, this.onPressed});

  final Function onPressed;
  final String username;
  final String email;

  List<Widget> getWidgetList(bool isFriends) {
    List<Widget> widgetList = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            username,
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          Text(
            email,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ];
    if (isFriends) {
      widgetList.insert(0, IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            //TODO: I dunno do something
          },
        ),
      );
    } else {
      widgetList.add(
        IconButton(
          icon: Icon(
            Icons.person_add,
          ),
          onPressed: onPressed,
        ),
      );
    }
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            elevation: 2.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: (isFriends) ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                children: getWidgetList(isFriends),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsersStream extends StatelessWidget {
  UsersStream({this.currentUserEmail});

  final String currentUserEmail;
  final usersRef = _firestore.collection('users');

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: (isFriends) ?
          (currentUserEmail != null) ? usersRef.document(currentUserEmail).collection('friends').snapshots() : null
          : usersRef.orderBy('username').snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(
              child: SpinKitRing(
                color: Colors.blue,
              ),
            );
          }
          final people = snapshot.data.documents;
          List<PersonListTile> personListTiles = [];
          for (var person in people) {
            final username = person.data['username'];
            final email = person.data['email'];

            final personListTile = PersonListTile(
              username: username,
              email: email,
              onPressed: () {
                var userFriendsRef = _firestore.collection('users').document(currentUserEmail).collection('friends');
                userFriendsRef.document(email).setData(
                    {
                      'username' : username,
                      'email' : email,
                    }
                );
                showAddedToFriendsSnackBar(username, context);
              },
            );
            if(personListTile.email != currentUserEmail) personListTiles.add(personListTile);
          }
          return ListView.builder(
            itemCount: personListTiles.length,
            itemBuilder: (context, index) {
              return personListTiles[index];
            },
          );
        },
      ),
    );
  }
}

//TODO: Switch between chats and people
