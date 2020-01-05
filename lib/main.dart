import 'package:flutter/material.dart';
import 'package:messengerger/screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/all_people_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        AllPeopleListScreen.id: (context) => AllPeopleListScreen(),
      },
    );
  }
}