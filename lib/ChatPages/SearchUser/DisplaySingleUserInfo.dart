///to display tile for particular user of search result

import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/SearchUser/DisplayResult.dart';
import 'package:insta_clone/images.dart';

class DisplaySingleInfo extends StatefulWidget {
  final Users? user;
  const DisplaySingleInfo({this.user, Key? key}) : super(key: key);

  @override
  _DisplaySingleInfoState createState() => _DisplaySingleInfoState();
}

class _DisplaySingleInfoState extends State<DisplaySingleInfo> {
  String? uid;
  String? nickName = '';
  List<String>? favorite = [];
  List<String>? following = [];

  getValue() async {
    if (this.mounted) {
      uid = await SharedPreferencesHelper().getUserUid();
      favorite = await SharedPreferencesHelper().getUserFavorite();
      following = await SharedPreferencesHelper().getUserFollowing();
      nickName = await SharedPreferencesHelper().getUserDisplayName();
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
                      userUid: widget.user!.userUid,
                      displayName: widget.user!.displayName,
                      myUid: uid,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  widget.user!.photoUrl != null
                      ? ClipRRect(
                          child: ImagesWidget(
                              image: widget.user!.photoUrl!,
                              width: 50.0,
                              height: 50.0),
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
                        widget.user!.displayName!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        widget.user!.userName!,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            favorite!.contains(widget.user!.userUid)
                ? ElevatedButton(
                    onPressed: () async {
                      if (favorite!.contains(widget.user!.userUid)) {
                        favorite!.remove(widget.user!.userUid);
                        await FirebaseApi().addFavorite(uid!, favorite!);
                        await SharedPreferencesHelper()
                            .setUserFavorite(favorite);
                        setState(() {});
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResult(
                              following: following,
                              myNickName: nickName,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text('Remove'),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      if (!favorite!.contains(widget.user!.userUid)) {
                        favorite!.add(widget.user!.userUid!);
                        await FirebaseApi().addFavorite(uid!, favorite!);
                        await SharedPreferencesHelper()
                            .setUserFavorite(favorite);
                        setState(() {});
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResult(
                              following: following,
                              myNickName: nickName,
                            ),
                          ),
                        );
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
