///to build tile for particular chat room

import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/Chat/ChatPage.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/images.dart';

class SearchDisplay extends StatefulWidget {
  final Users? user;
  const SearchDisplay({this.user, Key? key}) : super(key: key);

  @override
  _SearchDisplayState createState() => _SearchDisplayState();
}

class _SearchDisplayState extends State<SearchDisplay> {
  String? myUid = "";
  String? myDisplayName = "";
  String? chatRoomId = "";

  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      myDisplayName = await SharedPreferencesHelper().getUserDisplayName();
      chatRoomId = DataBaseMethod()
          .getChatRoomIdByUserNames(myUid!, widget.user!.userUid!);

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
      child: GestureDetector(
        onTap: () async {
          Map<String, dynamic> chatRoomInfoMap = {
            'ChatRoomId': chatRoomId,
            'userNames': [widget.user!.displayName, myDisplayName!],
          };
          await FirebaseApi().createNewChatRoom(chatRoomInfoMap, chatRoomId);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                user: widget.user,
                chatRoomId: chatRoomId,
              ),
            ),
          );
        },
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
      ),
    );
  }
}
