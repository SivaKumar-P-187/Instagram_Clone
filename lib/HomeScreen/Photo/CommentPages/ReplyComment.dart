///Build reply comment widget

import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/commentJson.dart';

class ReplyComment extends StatelessWidget {
  final Comment? comment;
  final VoidCallback? onCancelReply;
  const ReplyComment({
    Key? key,
    required this.comment,
    this.onCancelReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white.withAlpha(5),
        child: Row(
          children: [
            Container(
              color: Colors.green,
              width: 4,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                child: buildReplyComment(),
              ),
            ),
          ],
        ),
      );
  Widget buildReplyComment() {
    return Row(
      children: [
        Expanded(
            child: Text(
          "Replying to ${comment!.userName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        )),
        if (onCancelReply != null)
          GestureDetector(
            child: Icon(Icons.close, size: 16),
            onTap: onCancelReply,
          )
      ],
    );
  }
}
