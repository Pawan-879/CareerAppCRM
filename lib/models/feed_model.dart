// To parse this JSON data, do
//
//     final feedModel = feedModelFromJson(jsonString);

import 'dart:convert';

FeedModel feedModelFromJson(String str) => FeedModel.fromJson(json.decode(str));

String feedModelToJson(FeedModel data) => json.encode(data.toJson());

class FeedModel {
  FeedModel({
    this.status,
    this.response,
    this.data,
  });

  String? status;
  String? response;
  List<FeedItem>? data;

  factory FeedModel.fromJson(Map<String, dynamic> json) => FeedModel(
        status: json["status"],
        response: json["response"],
        data:
            List<FeedItem>.from(json["data"].map((x) => FeedItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class FeedItem {
  FeedItem({
    this.id,
    this.title,
    this.body,
    this.postCategoryName,
    this.image,
    this.mediaType,
    this.createdBy,
    this.updatedAt,
    this.scheduled_at,

    this.createdAt,
    this.comments,
    this.likesCount,
  });

  String? id;
  String? title;
  String? body;
  String? postCategoryName;
  List<String>? image;
  String? mediaType;
  String? createdBy;
  String? scheduled_at;
  String? updatedAt;
  String? createdAt;
  List<FeedComment>? comments;
  LikesCount? likesCount;

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        postCategoryName: json["post_category_name"],
        image: List<String>.from(json["image"].map((x) => x)),
        mediaType: json["media_type"],
        createdBy: json["createdBy"],
        updatedAt: json["updatedAt"],
        createdAt: json["createdAt"],
        scheduled_at: json["scheduled_at"],
        comments: List<FeedComment>.from(
            json["comments"].map((x) => FeedComment.fromJson(x))),
        likesCount: LikesCount.fromJson(json["likesCount"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "post_category_name": postCategoryName,
        "image": List<String>.from(image!.map((x) => x)),
        "media_type": mediaType,
        "createdBy": createdBy,
        "updatedAt": updatedAt,
        "createdAt": createdAt,
        "scheduled_at": scheduled_at,
        "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
        "likesCount": likesCount!.toJson(),
      };
}

class FeedComment {
  FeedComment({
    this.id,
    this.postId,
    this.userId,
    this.comment,
    this.status,
    this.userName,
  });

  String? id;
  String? postId;
  String? userId;
  String? comment;
  String? status;
  String? userName;

  factory FeedComment.fromJson(Map<String, dynamic> json) => FeedComment(
        id: json["id"],
        postId: json["post_id"],
        userId: json["user_id"],
        comment: json["comment"],
        status: json["status"],
        userName: json["user_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "post_id": postId,
        "user_id": userId,
        "comment": comment,
        "status": status,
        "user_name": userName,
      };
}

class LikesCount {
  LikesCount({
    this.totalLikes,
  });

  String? totalLikes;

  factory LikesCount.fromJson(Map<String, dynamic> json) => LikesCount(
        totalLikes: json["total_likes"],
      );

  Map<String, dynamic> toJson() => {
        "total_likes": totalLikes,
      };
}
