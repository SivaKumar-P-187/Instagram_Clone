// To parse this JSON data, do
//
//     final reportBug = reportBugFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<ReportBug> reportBugFromJson(String str) =>
    List<ReportBug>.from(json.decode(str).map((x) => ReportBug.fromJson(x)));

String reportBugToJson(List<ReportBug> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReportBug {
  ReportBug({
    @required this.userUid,
    @required this.userName,
    @required this.error,
    @required this.time,
    @required this.image,
  });

  final String? userUid;
  final String? userName;
  final String? error;
  final DateTime? time;
  final List<dynamic>? image;

  factory ReportBug.fromJson(Map<String, dynamic> json) => ReportBug(
        userUid: json["userUid"],
        userName: json["userName"],
        error: json["error"],
        time: DateTime.parse(json["time"]),
        image: List<dynamic>.from(json["image"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "userUid": userUid,
        "userName": userName,
        "error": error,
        "time": time!.toIso8601String(),
        "image": List<dynamic>.from(image!.map((x) => x)),
      };
}
