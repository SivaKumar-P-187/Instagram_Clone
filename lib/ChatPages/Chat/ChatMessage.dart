///To display message of particular chat room

import 'package:flutter/material.dart';

///list tile swipe
import 'package:swipe_to/swipe_to.dart';

///other class packages
import 'package:insta_clone/Json/messageJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/Chat/Message_Widget.dart';

class ChatMessage extends StatefulWidget {
  final String? chatRoomId;
  final ValueChanged<Message>? onSwipedMessage;
  const ChatMessage({this.chatRoomId, @required this.onSwipedMessage, Key? key})
      : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  List<Message>? message = [];
  String? myNickName = "";
  getValue() async {
    if (this.mounted) {
      myNickName = await SharedPreferencesHelper().getUserDisplayName();
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
    return StreamBuilder<List<Message>>(
        stream: FirebaseApi().getChatRooms(widget.chatRoomId, myNickName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            message = snapshot.data!;
            if (message!.length > 0) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 0.0, top: 100),
                      itemCount: message!.length,
                      primary: true,
                      reverse: true,
                      itemBuilder: (context, int index) {
                        return SwipeTo(
                          onRightSwipe: () {
                            widget.onSwipedMessage!(message![index]);
                          },
                          child: MessageWidget(
                            message: message![index],
                            isMe: message![index].messageSendBy == myNickName,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    bottom: 100,
                    left: 40,
                    right: 40,
                  ),
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Theme.of(context).cardTheme.color,
                    child: Center(
                      child: Text(
                        "Say Hi..",
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
