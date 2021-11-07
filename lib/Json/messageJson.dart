// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'package:insta_clone/Json/utils.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

List<Message> messageFromJson(String str) =>
    List<Message>.from(json.decode(str).map((x) => Message.fromJson(x)));

String messageToJson(List<Message> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Message {
  Message({
    @required this.chatRoomId,
    @required this.docId,
    @required this.photoUrl,
    @required this.message,
    @required this.messageTime,
    @required this.messageSendBy,
    @required this.replyMessage,
  });

  final String? photoUrl;
  final String? message;
  final String? docId;
  final String? chatRoomId;
  final DateTime? messageTime;
  final String? messageSendBy;
  final Message? replyMessage;

  static Message fromJson(Map<String, dynamic> json) => Message(
        chatRoomId: json["chatRoomId"],
        docId: json["docId"],
        photoUrl: json["photoUrl"],
        message: json["message"],
        messageTime: Utils.toDateTime(json['messageTime']),
        messageSendBy: json["messageSendBy"],
        replyMessage: json["replyMessage"] == null
            ? null
            : Message.fromJson(json["replyMessage"]),
      );

  Map<String, dynamic> toJson() => {
        "chatRoomId": chatRoomId!,
        "docId": docId!,
        "photoUrl": photoUrl!,
        "message": message!,
        "messageTime": Utils.fromDateTimeToJson(messageTime),
        "messageSendBy": messageSendBy!,
        "replyMessage": replyMessage == null ? null : replyMessage!.toJson(),
      };
}

//DateTime.parse(json["messageTime"])

//messageTime!.toIso8601String()
