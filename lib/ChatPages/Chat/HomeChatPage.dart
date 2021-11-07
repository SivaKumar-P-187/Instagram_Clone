///To ge all chat room of particular users
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///date format
import 'package:intl/intl.dart';

///other class package
import 'package:insta_clone/ChatPages/SearchUser/SearchChatScreen.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/Chat/ChatRoomTile.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? myNickName = '';
  Stream? message;
  String? myUid = "";
  List<Users> queryResultSet = [];
  Users? user;
  getValue() async {
    if (this.mounted) {
      myNickName = await SharedPreferencesHelper().getUserDisplayName();
      myUid = await SharedPreferencesHelper().getUserUid();
      message = await FirebaseApi().getAllChatRoomOfCurrentUser(myNickName!);
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
      padding: EdgeInsets.only(top: 5),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
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
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                HomeChatScreen(
                  choose: false,
                ),
                Expanded(
                  child: getAllChats(),
                )
              ],
            ),
          )),
    );
  }

  ///get all chats
  Widget getAllChats() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.54,
        child: StreamBuilder(
          stream: message,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: (snapshot.data as QuerySnapshot).docs.length,
                    itemBuilder: (context, int index) {
                      DocumentSnapshot ds =
                          (snapshot.data! as QuerySnapshot).docs[index];
                      DateTime time = DateTime.fromMicrosecondsSinceEpoch(
                          ds['lastMessageTime'].microsecondsSinceEpoch);
                      String formattedTime = DateFormat.jm().format(time);
                      String? chatRoom = ds['ChatRoomId'];
                      String? uid =
                          chatRoom!.replaceAll(myUid!, "").replaceAll("_", "");
                      return StreamBuilder<List<Users>>(
                          stream: FirebaseApi().getSingleUserInfo(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              queryResultSet = snapshot.data!;
                              queryResultSet.forEach((element) {
                                if (element.userUid == uid) {
                                  user = element;
                                }
                              });
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ChatRoomIdTile(
                              lastMessage: ds['message'],
                              chatRoomId: ds.id,
                              myDisplayName: myNickName,
                              lastMessageTime: formattedTime,
                              myUid: myUid,
                              user: user,
                            );
                          });
                    })
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
    );
  }
}
