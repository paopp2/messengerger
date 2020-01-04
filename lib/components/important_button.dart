import 'package:flutter/material.dart';

class ImportantButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const ImportantButton({
    this.text,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 10,
      ),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 0,
        ),
        color: Colors.blue,
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}