class MessageModel {
  MessageModel({
    required this.msg,
    required this.formId,
    required this.toId,
    required this.read,
    required this.type,
    required this.sent,
  });
  late final String msg;
  late final String formId;
  late final String toId;
  late final String read;
  late final String sent;
  late final Type type;

  MessageModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    formId = json['formId'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['formId'] = formId;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type{text, image}
