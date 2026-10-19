// To parse this JSON data, do
//
//     final shortsModel = shortsModelFromJson(jsonString);

import 'dart:convert';

ShortsModel shortsModelFromJson(String str) =>
    ShortsModel.fromJson(json.decode(str));

String shortsModelToJson(ShortsModel data) => json.encode(data.toJson());

class ShortsModel {
  ShortsModel({
    this.status,
    this.response,
    this.data,
  });

  String? status;
  String? response;
  List<ShortItem>? data;

  factory ShortsModel.fromJson(Map<String, dynamic> json) => ShortsModel(
        status: json["status"],
        response: json["response"],
        data: List<ShortItem>.from(
            json["data"].map((x) => ShortItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ShortItem {
  ShortItem({
    this.id,
    this.title,
    this.image,
    this.code,
    this.created,
    this.comments,
    this.likesCount,
  });

  String? id;
  String? title;
  String? image;
  String? code;
  String? created;
  List<Comment>? comments;
  ShortsLikesCount? likesCount;

  factory ShortItem.fromJson(Map<String, dynamic> json) => ShortItem(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        code: json["code"],
        created: json["created"],
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        likesCount: ShortsLikesCount.fromJson(json["likesCount"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "code": code,
        "created": created,
        "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
        "likesCount": likesCount!.toJson(),
      };
}

class Comment {
  Comment({
    this.id,
    this.shortVideoId,
    this.userId,
    this.comment,
    this.status,
    this.created,
    this.userName,
  });

  String? id;
  String? shortVideoId;
  String? userId;
  String? comment;
  String? status;
  String? created;
  String? userName;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        shortVideoId: json["short_video_id"],
        userId: json["user_id"],
        comment: json["comment"],
        status: json["status"],
        created: json["created"],
        userName: json["user_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "short_video_id": shortVideoId,
        "user_id": userId,
        "comment": comment,
        "status": status,
        "created": created,
        "user_name": userName,
      };
}

class ShortsLikesCount {
  ShortsLikesCount({
    this.totalLikes,
  });

  String? totalLikes;

  factory ShortsLikesCount.fromJson(Map<String, dynamic> json) =>
      ShortsLikesCount(
        totalLikes: json["total_likes"],
      );

  Map<String, dynamic> toJson() => {
        "total_likes": totalLikes,
      };
}
