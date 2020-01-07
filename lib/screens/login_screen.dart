import 'package:flutter/material.dart';
import 'package:messengerger/components/important_button.dart';
import 'package:messengerger/screens/chat_list_screen.dart';
import 'package:messengerger/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/services.dart';
import 'package:messengerger/constants.dart';

const welcomeMessage =
'''Welcome to 
Messengerger''';
FirebaseAuth fireAuth = FirebaseAuth.instance;
enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String email;
  String password;
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
        backgroundColor: Colors.white,
        body: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 80,
                      left: 100,
                      right: 100,
                      bottom: 30,
                    ),
                    child: Container(
                      child: Hero(
                        tag: 'messenger_icon',
                        child: Image(
                          image: AssetImage('images/messenger_icon.png'),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        welcomeMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Class A',
                        style: TextStyle(
                            fontSize: 1
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
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
                          decoration: getTextfieldDecoration('Password'),
                          obscureText: true,
                        ),
                      ),
                      ImportantButton(
                        text: 'LOG IN',
                        onPressed: () async {
                          setState(() {
                            registering = true;
                          });
                          try {
                            AuthResult result = await fireAuth.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            showLoadingCircle(false);
                            Navigator.pushNamed(
                              context,
                              ChatListScreen.id,
                              arguments: result.user,
                            );
                          } on PlatformException catch (error) {
                            // handle the firebase specific error
                            print('somethings wrong');
                            showLoadingCircle(false);
                            return _buildErrorDialog(context, error.message);
                          } on Exception catch (error) {
                            // gracefully handle anything else that might happen..
                            print('do something please');
                            showLoadingCircle(false);
                            return _buildErrorDialog(context, error.toString());
                          }
                        },
                      ),
                      SecondaryButton(
                          text: 'NO ACCOUNT?',
                          onPressed: () {
                            Navigator.pushNamed(context, RegisterScreen.id);
                          }
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        )
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    this.onPressed,
    this.text,
  });

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 10,
      ),
      child: FlatButton(
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 0,
        ),
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future _buildErrorDialog(BuildContext context, _message) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Login Error'),
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