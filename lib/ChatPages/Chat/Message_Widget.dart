///To format particular message of chat room

import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

///date format
import 'package:intl/intl.dart';

///other class packages
import 'package:insta_clone/Json/messageJson.dart';
import 'package:insta_clone/ChatPages/Chat/ReplyMessageWidget.dart';

class MessageWidget extends StatefulWidget {
  final Message? message;
  final bool? isMe;

  const MessageWidget({this.message, this.isMe, Key? key}) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);
    return Row(
      mainAxisAlignment:
          widget.isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!widget.isMe!)
          imageWidget(
            image: widget.message!.photoUrl!,
            height: 30.toDouble(),
            width: 30.toDouble(),
          ),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: width * 3 / 5),
          decoration: BoxDecoration(
            color: widget.isMe!
                ? Theme.of(context).scaffoldBackgroundColor == Colors.white
                    ? Colors.grey[200]
                    : Colors.deepPurple
                : Theme.of(context).scaffoldBackgroundColor == Colors.white
                    ? Colors.green.shade200
                    : Color(0XFF075E54),
            borderRadius: widget.isMe!
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessageScreen(message: widget.message, isMe: widget.isMe),
        ),
      ],
    );
  }

  ///to display container for particular message
  buildMessageScreen({Message? message, bool? isMe}) {
    DateTime time = DateTime.fromMicrosecondsSinceEpoch(
        message!.messageTime!.microsecondsSinceEpoch);
    String formattedTime = DateFormat.jm().format(time);
    final replyMessageNull = Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: !isMe! ? 0 : 8,
            right: isMe ? 35 : 29,
            top: 5,
            bottom: 10,
          ),
          child: Text(
            message.message!,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Row(
            children: [
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (message.replyMessage == null) {
      return replyMessageNull;
    } else {
      return Column(
        crossAxisAlignment: isMe && message.replyMessage == null
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          buildReplyMessage(message),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: !isMe ? 0 : 8,
                    right: isMe ? 35 : 29,
                    top: 5,
                    bottom: 10,
                  ),
                  child: Text(
                    message.message!,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  ///to display container for reply message
  buildReplyMessage(Message message) {
    final reply = message.replyMessage;
    final isReply = reply != null;
    if (!isReply) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        child: ReplyMessageWidget(
          message: reply,
        ),
      );
    }
  }

  ///to build image for particular message
  imageWidget({String? image, double? height, width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
