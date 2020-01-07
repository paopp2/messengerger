import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messengerger/components/important_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messengerger/constants.dart';
import 'package:messengerger/screens/chat_list_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'people_list_screen.dart';

final fireAuth = FirebaseAuth.instance;
final fireStore = Firestore.instance;


class RegisterScreen extends StatefulWidget {
  static const id = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  String username;
  String email;
  String password;
  String rePassword;
  bool registering = false;

  void showLoadingCircle(bool show) {
    setState(() {
      registering = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: registering,
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 80,
                      left: 100,
                      right: 100,
                      bottom: 30,
                    ),
                    child: Hero(
                      tag: 'messenger_icon',
                      child: Image(
                        image: AssetImage('images/messenger_icon.png'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 50,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      username = value;
                    },
                    textAlign: TextAlign.center,
                    decoration: getTextfieldDecoration('Enter username'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 50,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      email = value;
                    },
                    textAlign: TextAlign.center,
                    decoration: getTextfieldDecoration('Enter email'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 50,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      password = value;
                    },
                    textAlign: TextAlign.center,
                    decoration: getTextfieldDecoration('Enter password'),
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 50,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      rePassword = value;
                    },
                    textAlign: TextAlign.center,
                    decoration: getTextfieldDecoration('Re-enter password'),
                    obscureText: true,
                  ),
                ),
                ImportantButton(
                  text: 'Sign up',
                  onPressed: () async {
                    showLoadingCircle(true);
                    AuthResult newUser;
                    try{
                      if (password != rePassword) {
                        showLoadingCircle(false);
                        return _buildErrorDialog(context, 'Passwords does not match');
                      } else {
                        newUser = await fireAuth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                      }
                      if(newUser != null) {
                        showLoadingCircle(false);
                        final user = await fireAuth.currentUser();
                        print(user.email);
                        try {
                          var ref = await fireStore.collection('users').document(email).setData({
                            'username' : username,
                            'email' : email,
                            'password' : password,
                          });
                          showLoadingCircle(false);
                          Navigator.pushNamed(
                              context,
                              ChatListScreen.id,
                              arguments: user,
                          );
                        } on PlatformException catch (error) {
                          // handle the firebase specific error
                          showLoadingCircle(false);
                          return _buildErrorDialog(context, error.message);
                        } on Exception catch (error) {
                          // gracefully handle anything else that might happen..
                          showLoadingCircle(false);
                          return _buildErrorDialog(context, error.toString());
                        }
                      }
                    } on PlatformException catch (error) {
                      // handle the firebase specific error
                      showLoadingCircle(false);
                      return _buildErrorDialog(context, error.message);
                    } on Exception catch (error) {
                      // gracefully handle anything else that might happen..
                      showLoadingCircle(false);
                      return _buildErrorDialog(context, error.toString());
                    }
                  },
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future _buildErrorDialog(BuildContext context, _message) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Sign up Error'),
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      );
    },
    context: context,
  );
}
