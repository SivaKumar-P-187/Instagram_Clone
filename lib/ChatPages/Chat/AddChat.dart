///This file is used to add message to firestore at particular chat room

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///random string
import 'package:random_string/random_string.dart';

///other class packages
import 'package:insta_clone/Json/messageJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/ChatPages/Chat/ReplyMessageWidget.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';

class AddMessage extends StatefulWidget {
  final String? chatRoomId, photoUrl, nickName;
  final FocusNode? focusNode;
  final Message? replyMessage;
  final VoidCallback? onCancelReply;
  const AddMessage(
      {this.chatRoomId,
      this.nickName,
      this.photoUrl,
      this.focusNode,
      this.replyMessage,
      this.onCancelReply,
      Key? key})
      : super(key: key);

  @override
  _AddMessageState createState() => _AddMessageState();
}

class _AddMessageState extends State<AddMessage> {
  TextEditingController messageTextFieldController = TextEditingController();
  String? messageId = "";

  @override
  Widget build(BuildContext context) {
    final isReply = widget.replyMessage != null;
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (isReply) buildReply(),
                      TextField(
                        focusNode: widget.focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  isReply ? Radius.zero : Radius.circular(24),
                              topRight:
                                  isReply ? Radius.zero : Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).scaffoldBackgroundColor ==
                                      Colors.white
                                  ? Colors.grey[100]
                                  : Colors.black26,
                          hintText: 'Type your message',
                        ),
                        controller: messageTextFieldController,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                GestureDetector(
                  onTap: () {
                    addMessage();
                  },
                  child: Center(
                      child: Container(
                    child: Icon(
                      Icons.send,
                      size: 35,
                      color: Colors.blue,
                    ),
                  )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  ///to add message to firestore at particular chat room
  addMessage() {
    if (messageTextFieldController.text != '') {
      String message = messageTextFieldController.text;
      var lastMessageTime = DateTime.now().toLocal();
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      final chatInfo = Message(
        chatRoomId: widget.chatRoomId,
        docId: messageId,
        photoUrl: widget.photoUrl,
        message: message,
        messageTime: lastMessageTime,
        messageSendBy: widget.nickName,
        replyMessage: widget.replyMessage,
      );
      FirebaseApi()
          .addMessageToFireBase(
        message: chatInfo.toJson(),
        messageId: messageId,
        chatRoomId: widget.chatRoomId,
      )
          .then((value) {
        Map<String, dynamic> lastMessageInfo = {
          'message': message,
          'lastMessageTime': lastMessageTime,
          'lastMessageSendBy': widget.nickName,
        };
        FirebaseApi()
            .updateLastMessage(lastMessageInfo, widget.chatRoomId)
            .then((value) {});
      }).catchError((e) {
        ErrorHandler().errorDialog(context, e);
      });
      messageId = "";
      messageTextFieldController.text = '';
      if (widget.replyMessage != null) {
        sendMessage();
      }
      setState(() {});
    }
  }

  ///once after message added to un focus the keyboard and clear reply message
  void sendMessage() async {
    FocusScope.of(context).unfocus();
    widget.onCancelReply!();
  }

  ///if there is reply message --> build container above the keyboard
  Widget buildReply() => Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            )),
        child: ReplyMessageWidget(
          message: widget.replyMessage,
          onCancelReply: widget.onCancelReply,
        ),
      );
}
