///To display chat room tile for particular users

import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/ChatPages/Chat/ChatPage.dart';
import 'package:insta_clone/images.dart';

class ChatRoomIdTile extends StatefulWidget {
  final String? lastMessage, chatRoomId, myDisplayName, lastMessageTime, myUid;
  final Users? user;
  const ChatRoomIdTile(
      {this.lastMessage,
      this.chatRoomId,
      this.myDisplayName,
      this.lastMessageTime,
      this.myUid,
      this.user,
      Key? key})
      : super(key: key);

  @override
  _ChatRoomIdTileState createState() => _ChatRoomIdTileState();
}

class _ChatRoomIdTileState extends State<ChatRoomIdTile> {
  String? chatDisplayName = "", photoUrl = "", userUid = "";
  Map<String, dynamic>? documentData;

  ///to get all chat room id of current user and user
  getChatUserInfo() async {
    if (this.mounted) {
      userUid =
          widget.chatRoomId!.replaceAll(widget.myUid!, "").replaceAll("_", "");
      await FirebaseApi().getUserUidInfo(userUid!).then((documentSnapshot) {
        if (documentSnapshot.docs.isNotEmpty) {
          documentData =
              documentSnapshot.docs.single.data() as Map<String, dynamic>;
        }
      });
      if (this.mounted) {
        setState(() {
          chatDisplayName = documentData!['displayName'];
          photoUrl = documentData!['photoUrl'];
        });
      }
    }
  }

  ///build on launch
  buildOnLaunch() async {
    await getChatUserInfo();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: widget.chatRoomId,
              user: widget.user,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 8, left: 8, bottom: 5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).backgroundColor,
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 0.0), // shadow direction: bottom right
              )
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    photoUrl != null
                        ? ClipRRect(
                            child: ImagesWidget(
                                image: photoUrl!, width: 50.0, height: 50.0),
                            borderRadius: BorderRadius.circular(25),
                          )
                        : Container(),
                    SizedBox(
                      width: 20.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          child: Text(
                            chatDisplayName!,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 3),
                        Container(
                          width: 200,
                          child: Text(
                            widget.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Text(
                widget.lastMessageTime!,
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
