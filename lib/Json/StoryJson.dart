//
//     final story = storyFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

enum MediaType { image, text, video }

List<Story> storyFromJson(String str) =>
    List<Story>.from(json.decode(str).map((x) => Story.fromJson(x)));

String storyToJson(List<Story> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Story {
  Story({
    @required this.url,
    @required this.time,
    @required this.media,
    @required this.caption,
    @required this.duration,
    @required this.viewCount,
    @required this.viewList,
  });

  final String? url;
  final DateTime? time;
  final MediaType? media;
  final String? caption;
  final int? duration;
  final int? viewCount;
  final List<dynamic>? viewList;

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        url: json["url"],
        time: DateTime.parse(json["time"]),
        media: MediaType.values[json["media"]],
        caption: json["caption"],
        duration: json["Duration"],
        viewCount: json["viewCount"],
        viewList: List<dynamic>.from(json["viewList"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "time": time!.toIso8601String(),
        "media": media!.index,
        "caption": caption,
        "Duration": duration,
        "viewCount": viewCount,
        "viewList": List<dynamic>.from(viewList!.map((x) => x)),
      };
}
