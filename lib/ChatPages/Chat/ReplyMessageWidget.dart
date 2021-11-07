///to Build reply message container

import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/messageJson.dart';

class ReplyMessageWidget extends StatelessWidget {
  final Message? message;
  final VoidCallback? onCancelReply;

  const ReplyMessageWidget({
    @required this.message,
    this.onCancelReply,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Container(
          color: Colors.green.withOpacity(0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.green,
                width: 4,
              ),
              const SizedBox(width: 8),
              Expanded(child: buildReplyMessage()),
            ],
          ),
        ),
      );

  Widget buildReplyMessage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${message!.messageSendBy}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (onCancelReply != null)
                GestureDetector(
                  child: Icon(Icons.close, size: 16),
                  onTap: onCancelReply,
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(message!.message!, style: TextStyle(color: Colors.black54)),
        ],
      );
}
