///To display the current user details

import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/images.dart';

class DisplaySingleInfo extends StatefulWidget {
  final List<Users>? user;
  final bool? choose;
  const DisplaySingleInfo({this.user, this.choose, Key? key}) : super(key: key);

  @override
  _DisplaySingleInfoState createState() => _DisplaySingleInfoState();
}

class _DisplaySingleInfoState extends State<DisplaySingleInfo> {
  String? myUid;
  bool isSmall = true;
  bool addUser = true;
  bool findFavorite = true;
  List<String>? favorite = [];
  List<Users>? addFavorite = [];
  List<Users>? removeFavorite = [];
  List<Users>? temp = [];
  getValue() async {
    if (this.mounted) {
      favorite = await SharedPreferencesHelper().getUserFavorite();
      myUid = await SharedPreferencesHelper().getUserUid();
      findFavorite = widget.user!.length > 0 ? true : false;
      widget.user!.forEach((element) {
        if (favorite!.length == 0) {
          addFavorite!.add(element);
        } else if (favorite!.contains(element.userUid!)) {
          removeFavorite!.add(element);
        } else {
          addFavorite!.add(element);
        }
        setState(() {});
      });
      isSmall = widget.choose! ? false : true;
      temp = widget.choose! ? addFavorite : removeFavorite;
      setState(() {});
      setState(() {});
    }
  }

  buildOnLaunch() async {
    getValue();
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
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        isSmall = !isSmall;
                        temp = addFavorite;
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        width: isSmall ? 50 : 260,
                        height: 50,
                        child:
                            isSmall ? buildShrinkedAdd() : buildStretchedAdd(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        isSmall = !isSmall;
                        temp = removeFavorite;
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        width: !isSmall ? 50 : 260,
                        height: 50,
                        child: isSmall
                            ? buildStretchedRemove()
                            : buildShrinkedRemove(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            temp!.length > 0
                ? ListView.builder(
                    primary: true,
                    shrinkWrap: true,
                    itemCount: temp!.length,
                    itemBuilder: (context, int index) {
                      final user = temp![index];
                      return buildUserTile(user);
                    },
                  )
                : !isSmall
                    ? Expanded(
                        child: Container(
                          child: Center(
                            child: Text('All Users Are Favorite'),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Container(
                          child: Center(
                            child: Text('No Favorite Users'),
                          ),
                        ),
                      )
          ],
        ),
      ),
    );
  }

  buildUserTile(Users user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userUid: user.userUid,
              displayName: user.displayName,
              myUid: myUid,
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
                  user.photoUrl != null
                      ? ClipRRect(
                          child: ImagesWidget(
                              image: user.photoUrl!, width: 50.0, height: 50.0),
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
              favorite!.contains(user.userUid)
                  ? ElevatedButton(
                      onPressed: () async {
                        favorite!.remove(user.userUid!);
                        removeFavorite!.remove(user);
                        addFavorite!.add(user);
                        if (!addUser) {
                          temp!.remove(user);
                        }
                        await SharedPreferencesHelper()
                            .setUserFavorite(favorite);
                        await FirebaseApi().addFavorite(myUid!, favorite!);
                        setState(() {});
                      },
                      child: Text('Remove'),
                      //color: Theme.of(context).buttonColor,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        favorite!.add(user.userUid!);
                        addFavorite!.remove(user);
                        removeFavorite!.add(user);
                        if (addUser) {
                          temp!.remove(user);
                        }
                        await SharedPreferencesHelper()
                            .setUserFavorite(favorite);
                        await FirebaseApi().addFavorite(myUid!, favorite!);
                        setState(() {});
                      },
                      child: Text('Add'),
                      // color: Theme.of(context).buttonTheme.copyWith(buttonColor: ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  ///build animate button for add favorite and remove favorite
  buttonBarWidget() {
    Row(
      children: [
        isSmall
            ? GestureDetector(
                onTap: () {
                  isSmall = !isSmall;
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  width: isSmall ? 50 : 200,
                  height: 50,
                  child: isSmall ? buildShrinkedAdd() : buildStretchedAdd(),
                ),
              )
            : GestureDetector(
                onTap: () {
                  isSmall = false;
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  width: !isSmall ? 50 : 200,
                  height: 50,
                  child:
                      !isSmall ? buildShrinkedRemove() : buildStretchedRemove(),
                ),
              ),
      ],
    );
  }

  ///Add favorite button is active
  Widget buildStretchedAdd() => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.red, width: 2.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              'ADD',
              style: TextStyle(
                color: Colors.red,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  ///Add favorite button is inactive
  Widget buildShrinkedAdd() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.red,
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      );

  ///Remove favorite button is active
  Widget buildStretchedRemove() => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.red, width: 2.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              'REMOVE',
              style: TextStyle(
                color: Colors.red,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  ///Remove favorite button is inactive
  Widget buildShrinkedRemove() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.red,
        ),
        child: Icon(
          Icons.remove,
          color: Colors.white,
        ),
      );
}
