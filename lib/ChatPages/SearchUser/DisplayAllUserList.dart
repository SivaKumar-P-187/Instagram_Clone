///To display all user

import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/images.dart';

class DisplayAllUser extends StatefulWidget {
  final List<Users>? user;
  const DisplayAllUser({this.user, Key? key}) : super(key: key);

  @override
  _DisplayAllUserState createState() => _DisplayAllUserState();
}

class _DisplayAllUserState extends State<DisplayAllUser> {
  String? uid;
  List<String>? favorite = [];
  getValue() async {
    if (this.mounted) {
      uid = await SharedPreferencesHelper().getUserUid();
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            ListView.builder(
              primary: true,
              shrinkWrap: true,
              itemCount: widget.user!.length,
              itemBuilder: (context, int index) {
                final user = widget.user![index];
                return buildUserTile(user);
              },
            )
          ],
        ),
      ),
    );
  }

  ///build Tile for particular user
  buildUserTile(Users user) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userUid: user.userUid,
                      displayName: user.displayName,
                      myUid: uid,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  user.photoUrl != null
                      ? ClipRRect(
                          child: ImagesWidget(
                            image: user.photoUrl!,
                            width: 50.0,
                            height: 50.0,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        )
                      : Container(),
                  SizedBox(
                    width: 20.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        user.userName!,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            favorite!.contains(user.userUid)
                ? ElevatedButton(
                    onPressed: () async {
                      if (favorite!.contains(user.userUid)) {
                        favorite!.remove(user.userUid);
                        await FirebaseApi().addFavorite(uid!, favorite!);
                        await SharedPreferencesHelper()
                            .setUserFavorite(favorite);
                        setState(() {});
                      }
                    },
                    child: Text('Remove'),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      if (!favorite!.contains(user.userUid)) {
                        favorite!.add(user.userUid!);
                        await FirebaseApi().addFavorite(uid!, favorite!);
                        await SharedPreferencesHelper()
                            .setUserFavorite(favorite);
                        setState(() {});
                      }
                    },
                    child: Text('Add'),
                  ),
          ],
        ),
      ),
    );
  }
}
