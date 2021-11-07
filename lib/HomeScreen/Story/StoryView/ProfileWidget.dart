import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

///story
import 'package:sliding_sheet/sliding_sheet.dart';

///other class package
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';

class ProfileWidget extends StatelessWidget {
  final Users? user;
  final String? myUser;
  final Story? story;
  final ControllerCallback controllerCallback;
  final ControllerCallback controllerCallback1;
  final String? date;
  final BuildContext context;
  const ProfileWidget(
      {@required this.user,
      @required this.date,
      @required this.myUser,
      required this.controllerCallback,
      required this.controllerCallback1,
      required this.context,
      this.story,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget(user!.photoUrl!),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  user!.displayName == myUser
                      ? Text(
                          "My Story",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          user!.displayName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  Text(
                    date!,
                    style: TextStyle(color: Colors.white38),
                  )
                ],
              ),
            ),
            user!.displayName == myUser
                ? Padding(
                    padding: const EdgeInsets.only(right: 20, top: 5),
                    child: GestureDetector(
                      onTap: () {
                        // SheetController.of(context)!.state!.isShown
                        //     ? controllerCallback()
                        //     : controllerCallback1();
                        controllerCallback();
                        viewList();
                      },
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.clear,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  viewList() => showSlidingBottomSheet(
        context,
        builder: (context) => SlidingSheetDialog(
          cornerRadius: 16,
          avoidStatusBar: true,
          snapSpec: SnapSpec(
            initialSnap: 0.4,
            snappings: [0.4, 0.7, 1],
            snap: true,
          ),
          builder: buildSheet1,
          headerBuilder: buildHeader,
        ),
      );
  Widget buildSheet1(context, state) {
    return Material(
      child: StreamBuilder<List<Users>>(
        stream: FirebaseApi().getAllUserInfo(myUser!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //List<Users>? users = snapshot.data;
            List<Users> users = [];
            for (var user in snapshot.data!) {
              if (story!.viewList!.contains(user.userUid)) {
                users.add(user);
              }
            }
            return ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: users.length,
              itemBuilder: (context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).backgroundColor,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: imageWidget(users[index].photoUrl),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          users[index].displayName!,
                          style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  imageWidget(String? image) {
    return ClipOval(
      child: ImagesWidget(image: image, width: 50.0, height: 50.0),
    );
  }

  Widget buildHeader(BuildContext context, SheetState state) => Material(
        child: Container(
          color: Colors.blue,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 16,
              ),
              Center(
                child: Container(
                  height: 8,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      );
}
