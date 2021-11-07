import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/ChatPages/Chat/HomeChatPage.dart';
import 'package:insta_clone/ChatPages/FavoritePage/FavoriteHomePage.dart';

class MainHomeChatScreen extends StatefulWidget {
  const MainHomeChatScreen({Key? key}) : super(key: key);

  @override
  _MainHomeChatScreenState createState() => _MainHomeChatScreenState();
}

class _MainHomeChatScreenState extends State<MainHomeChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FavoriteHomePage(),
          Expanded(child: Container(child: ChatPage())),
        ],
      ),
    );
  }
}
