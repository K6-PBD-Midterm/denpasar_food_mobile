// lib/models/local_user.dart

import 'dart:convert';

LocalUser localUserFromJson(String str) => LocalUser.fromJson(json.decode(str));

String localUserToJson(LocalUser data) => json.encode(data.toJson());

class LocalUser {
  int id;
  String username;
  String email;
  bool isActive;
  bool isSuperuser;

  LocalUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    required this.isSuperuser,
  });

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        isActive: json["isActive"],
        isSuperuser: json["isSuperuser"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "isActive": isActive,
        "isSuperuser": isSuperuser,
      };
}