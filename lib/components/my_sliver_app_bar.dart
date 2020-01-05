import 'package:flutter/material.dart';

class MySliverAppBar extends StatelessWidget {
  const MySliverAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.blue,
      title: Text(
        "People",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25.0,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.person_add),
          tooltip: 'Add a friend',
          onPressed: () {},
        ),
      ],
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image(
          image: AssetImage('images/friends_at_home_kit8-net.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}