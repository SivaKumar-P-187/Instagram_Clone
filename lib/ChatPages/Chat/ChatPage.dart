///The home page of particular chat room
import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/Json/messageJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/ChatPages/Chat/AddChat.dart';
import 'package:insta_clone/MainHomeScreen.dart';
import 'package:insta_clone/ChatPages/Chat/ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  final Users? user;
  final String? chatRoomId;
  const ChatScreen({this.user, this.chatRoomId, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final focusNode = FocusNode();
  Message? replyMessage;
  TextEditingController messageTextFieldController = TextEditingController();
  String? photoUrl = "";
  String? nickName = "";
  String? messageId = "";
  getValue() async {
    if (this.mounted) {
      photoUrl = await SharedPreferencesHelper().getUserPhotoUrl();
      nickName = await SharedPreferencesHelper().getUserDisplayName();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(
          color: Theme.of(context).backgroundColor,
          onPressed: () {
            cancelReply();
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => MainHomeScreen(
                      pageControl: 2,
                    )));
          },
        ),
        centerTitle: true,
        title: Text(
          widget.user!.displayName!,
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  child: ChatMessage(
                    chatRoomId: widget.chatRoomId,
                    onSwipedMessage: (message) {
                      replyToMessage(message);
                      focusNode.requestFocus();
                    },
                  ),
                ),
              ),
              AddMessage(
                focusNode: focusNode,
                photoUrl: photoUrl,
                chatRoomId: widget.chatRoomId,
                nickName: nickName,
                replyMessage: replyMessage,
                onCancelReply: cancelReply,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///if swipe add reply message
  void replyToMessage(Message message) {
    setState(() {
      replyMessage = message;
    });
  }

  ///to cancel the reply message
  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }
}
