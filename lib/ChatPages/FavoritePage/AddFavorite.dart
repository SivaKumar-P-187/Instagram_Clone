///To add particular user to favorite user list  of current user

import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/ChatPages/SearchUser/SearchChatScreen.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/MainHomeScreen.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/FavoritePage/DisplaySingleUserInfo.dart';

class AddFavorite extends StatefulWidget {
  final bool? choose;
  const AddFavorite({this.choose, Key? key}) : super(key: key);

  @override
  _AddFavoriteState createState() => _AddFavoriteState();
}

class _AddFavoriteState extends State<AddFavorite> {
  List<Users> queryResultSet = [];
  List<Users> setQueryName = [];
  String? myNickName = '';
  List<String>? following = [];
  bool getChoose = false;
  getValue() async {
    if (this.mounted) {
      myNickName = await SharedPreferencesHelper().getUserDisplayName();
      following = await SharedPreferencesHelper().getUserFollowing();
      getChoose = widget.choose == null ? true : widget.choose!;
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: BackButton(
          color: Theme.of(context).backgroundColor,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainHomeScreen(
                  pageControl: 2,
                ),
              ),
            );
          },
        ),
        title: Text('Favorite Contact',
            style: Theme.of(context).textTheme.headline1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          HomeChatScreen(
            choose: true,
          ),
          Expanded(
            child: Container(
              child: getFollowingDetails(),
            ),
          ),
        ],
      ),
    );
  }

  ///To get all following users list of current user
  Widget getFollowingDetails() {
    return Container(
      child: StreamBuilder<List<Users>>(
        stream: FirebaseApi().getAllUserInfo(myNickName!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            setQueryName = [];
            queryResultSet = snapshot.data!;
            queryResultSet.forEach((element) {
              if (following!.contains(element.userUid)) {
                setQueryName.add(element);
              }
            });
          }
          return setQueryName.length > 0
              ? DisplaySingleInfo(
                  user: setQueryName,
                  choose: getChoose,
                )
              : emptyUserList();
        },
      ),
    );
  }

  ///If current user is not following any user
  emptyUserList() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text('No User Found'),
      ),
    );
  }
}
