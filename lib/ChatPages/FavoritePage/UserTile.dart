///User tile for favorite contact adding and removing

import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/images.dart';

class UserTile extends StatefulWidget {
  final Users? user;
  final String? myUid;
  final List<String>? favorite;
  const UserTile({this.user, this.myUid, this.favorite, Key? key})
      : super(key: key);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  List<Users>? addFavorite = [];
  List<Users>? removeFavorite = [];
  List<Users>? temp = [];
  bool addUser = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userUid: widget.user!.userUid,
              displayName: widget.user!.displayName,
              myUid: widget.myUid,
            ),
          ),
        );
      },
      child: Padding(
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
              Row(
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
              widget.favorite!.contains(widget.user!.userUid)
                  ? ElevatedButton(
                      onPressed: () async {
                        widget.favorite!.remove(widget.user!.userUid!);
                        removeFavorite!.remove(widget.user!);
                        addFavorite!.add(widget.user!);
                        if (!addUser) {
                          temp!.remove(widget.user!);
                        }
                        await SharedPreferencesHelper()
                            .setUserFavorite(widget.favorite);
                        await FirebaseApi()
                            .addFavorite(widget.myUid!, widget.favorite!);
                        setState(() {});
                      },
                      child: Text('Remove'),
                      //color: Theme.of(context).buttonColor,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        widget.favorite!.add(widget.user!.userUid!);
                        addFavorite!.remove(widget.user!);
                        removeFavorite!.add(widget.user!);
                        if (addUser) {
                          temp!.remove(widget.user!);
                        }
                        await SharedPreferencesHelper()
                            .setUserFavorite(widget.favorite);
                        await FirebaseApi()
                            .addFavorite(widget.myUid!, widget.favorite!);
                        setState(() {});
                      },
                      child: Text('Add'),
                      //color: Theme.of(context).buttonColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
