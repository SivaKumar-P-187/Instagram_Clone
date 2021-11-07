///Favorite home page

import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/ChatPages/Chat/ChatPage.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/ChatPages/FavoritePage/FavoriteItem.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/MenuIconHandler.dart';
import 'package:insta_clone/images.dart';

class FavoriteHomePage extends StatefulWidget {
  const FavoriteHomePage({Key? key}) : super(key: key);

  @override
  _FavoriteHomePageState createState() => _FavoriteHomePageState();
}

class _FavoriteHomePageState extends State<FavoriteHomePage> {
  String? myNickName = '';
  String? myUid;
  List<Users> queryResultSet = [];
  List<Users> setQueryName = [];
  List<Users> temp = [];
  List<String>? following = [];
  List<String>? favorite = [];

  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      myNickName = await SharedPreferencesHelper().getUserDisplayName();
      following = await SharedPreferencesHelper().getUserFollowing();
      favorite = await SharedPreferencesHelper().getUserFavorite();
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: Container(
          height: 160,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).backgroundColor,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 1.0), // shadow direction: bottom right
              )
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Favorite Contacts',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    PopupMenuButton<MenuItem>(
                      onSelected: (item) => onSelected(context, item),
                      itemBuilder: (context) => [
                        ...Menu.itemFirst.map(buildItem).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: getAllFavoriteList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///popup menu for editing favorite contact
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.black,
            ),
            SizedBox(
              width: 12,
            ),
            Text(item.title),
          ],
        ),
      );
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case Menu.addFavorite:
        Navigator.of(context).pushReplacementNamed('/addFavorite');
        break;
      case Menu.removeFavoritesItem:
        Navigator.of(context).pushReplacementNamed('/removeFavorite');
        break;
    }
  }

  ///to gey all favorite contact details
  getAllFavoriteList() {
    return StreamBuilder<List<Users>>(
        stream: FirebaseApi().getAllUserInfo(myNickName!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            setQueryName = [];
            temp = [];
            queryResultSet = snapshot.data!;
            queryResultSet.forEach((element) {
              if (following!.contains(element.userUid)) {
                setQueryName.add(element);
                if (favorite!.contains(element.userUid)) {
                  temp.add(element);
                }
              }
            });
          }
          return temp.length > 0
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: temp.length,
                  itemBuilder: (context, int index) {
                    if (index == 0) {
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.search,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: buildFavoriteTile(temp[index]),
                          ),
                        ],
                      );
                    }
                    return Container(
                      child: buildFavoriteTile(temp[index]),
                    );
                  })
              : Center(
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Add a Favorite',
                          style: Theme.of(context).textTheme.headline3)
                    ],
                  ),
                );
        });
  }

  ///to build favorite contact tile
  buildFavoriteTile(Users user) {
    return GestureDetector(
      onTap: () async {
        String? chatRoomId =
            DataBaseMethod().getChatRoomIdByUserNames(myUid!, user.userUid!);
        Map<String, dynamic> chatRoomInfoMap = {
          'ChatRoomId': chatRoomId,
          'userNames': [user.displayName, myNickName],
        };
        await FirebaseApi().createNewChatRoom(chatRoomInfoMap, chatRoomId);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: chatRoomId,
              user: user,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).backgroundColor,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 0.0), // shadow direction: bottom right
              )
            ],
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              user.photoUrl != null
                  ? ClipRRect(
                      child: ImagesWidget(
                          image: user.photoUrl!, width: 50.0, height: 50.0),
                      borderRadius: BorderRadius.circular(25),
                    )
                  : Container(),
              SizedBox(
                height: 2,
              ),
              Text(user.displayName!)
            ],
          ),
        ),
      ),
    );
  }
}
