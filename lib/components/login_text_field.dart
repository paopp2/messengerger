import 'package:flutter/material.dart';

class LogInTextField extends StatelessWidget {
  const LogInTextField({
    this.hintText,
    this.onChanged,
  });

  final String hintText;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 50,
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          enabledBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: Colors.lightBlueAccent, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: Colors.lightBlueAccent, width: 2.0),
          ),
        ),
      ),
    );
  }
}
