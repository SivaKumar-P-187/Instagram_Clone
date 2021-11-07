import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';
import 'package:insta_clone/images.dart';

class DisplayAllUser extends StatefulWidget {
  final List<Users>? user;
  const DisplayAllUser({this.user, Key? key}) : super(key: key);

  @override
  _DisplayAllUserState createState() => _DisplayAllUserState();
}

class _DisplayAllUserState extends State<DisplayAllUser> {
  String? uid;

  getValue() async {
    if (this.mounted) {
      uid = await SharedPreferencesHelper().getUserUid();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    if (mounted) {
      await getValue();
    }
  }

  @override
  void initState() {
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  buildUserTile(Users user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              displayName: user.displayName,
              userUid: user.userUid,
              myUid: uid!,
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
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(height: 3),
                  Text(
                    user.userName!,
                    style: Theme.of(context).textTheme.headline3,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
