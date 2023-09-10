class ChatUser {
  late final String id;
  late final String name;
  late final String about;
  late final String image;
  late final String pushToken;
  late final String createdAt;
  late final bool isOnline;
  late final String lastActive;
  late final String email;

  ChatUser({
    required this.email,
    required this.name,
    required this.id,
    required this.image,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
  });

  //  from json data to dart object
  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['createdAt'] ?? '';
    lastActive = json['lastActive'] ?? '';
    pushToken = json['pushToken'] ?? '';
    isOnline = json['isOnline'] ?? false ;
  }

  // dart object to json data

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['id'] = id;
    data['email'] = email;
    data['about'] = about;
    data['createdAt'] = createdAt;
    data['lastActive'] = lastActive;
    data['pushToken'] = pushToken;
    data['isOnline'] = isOnline;

    return data;
  }
}
