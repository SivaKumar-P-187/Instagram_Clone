///Search home screen

import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/ChatPages/Chat/SearchUserChat.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/SearchUser/DisplayResult.dart';

class HomeChatScreen extends StatefulWidget {
  final bool? choose;
  const HomeChatScreen({this.choose, Key? key}) : super(key: key);

  @override
  _HomeChatScreenState createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  bool isSearching = false;
  String? valuesName;
  String? myNickName;
  List<String>? following = [];
  List<Users> queryResultSet = [];
  List<Users> setQueryName = [];
  TextEditingController textEditingController = TextEditingController();

  getAllValues() async {
    if (this.mounted) {
      following = await SharedPreferencesHelper().getUserFollowing();
      myNickName = await SharedPreferencesHelper().getUserDisplayName();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getAllValues();
  }

  @override
  void initState() {
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: topScreen(),
    );
  }

  topScreen() {
    return GestureDetector(
      onTap: () {
        if (widget.choose!) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SearchResult(
                myNickName: myNickName,
                following: following,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SearchResultChat(
                myNickName: myNickName,
                following: following,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 0, left: 4, right: 4),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 30,
                color: Colors.grey.shade700,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Search',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
