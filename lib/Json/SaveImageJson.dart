// To parse this JSON data, do
//
//     final saveImageJson = saveImageJsonFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<SaveImageJson> saveImageJsonFromJson(String str) =>
    List<SaveImageJson>.from(
        json.decode(str).map((x) => SaveImageJson.fromJson(x)));

String saveImageJsonToJson(List<SaveImageJson> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SaveImageJson {
  SaveImageJson({
    @required this.userUid,
    @required this.docId,
  });

  final String? userUid;
  final String? docId;

  factory SaveImageJson.fromJson(Map<String, dynamic> json) => SaveImageJson(
        userUid: json["userUid"],
        docId: json["docId"],
      );

  Map<String, dynamic> toJson() => {
        "userUid": userUid,
        "docId": docId,
      };
}
