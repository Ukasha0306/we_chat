import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/auth/auth.dart';
import 'package:we_chat/model/message_model.dart';
import 'package:we_chat/screens/chat_screen.dart';
import 'package:we_chat/utils/my_date.dart';
import 'package:we_chat/widget/showing_profile_dialog.dart';
import '../model/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return ChangeNotifierProvider(
      create: (_) => Auth(),
      child: Consumer<Auth>(
        builder: (context, provider, child) {
          return Card(
            color: Colors.deepPurple.shade100,
            elevation: 1,
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        user: widget.user,
                      ),
                    ),
                  );
                },
                child: StreamBuilder(
                  stream: provider.getLastMessage(widget.user),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!.docs;
                      final list = data
                              .map((e) => MessageModel.fromJson(e.data()))
                              .toList() ??
                          [];
                      if (list.isNotEmpty) {
                        _message = list[0];
                      }
                    }
                    return Slidable(
                      endActionPane:  ActionPane(motion: const StretchMotion(), children: [
                        SlidableAction(onPressed: (context){
                          provider.deleteChat(
                              widget.user.email, widget.user);
                        },
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(7),
                            bottomRight: Radius.circular(7),
                          ),
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                        )
                      ]),
                      child: ListTile(
                        leading: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) =>
                                    ShowingProfileDialog(user: widget.user));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                )),
                          ),
                        ),
                        title: Text(widget.user.name),
                        subtitle: Text(
                          _message != null
                              ? _message!.type == Type.image
                                  ? 'Image'
                                  : _message!.msg
                              : widget.user.about,
                          maxLines: 1,
                        ),
                        trailing: _message == null
                            ? null // show nothing when no message is sent
                            : _message!.read.isEmpty &&
                                    _message!.formId != provider.user.uid
                                ? Container(
                                    height: mq.height * 0.03,
                                    width: mq.width * 0.03,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  )
                                : Text(
                                    MyDate.getLastMessage(
                                        context: context,
                                        time: _message!.sent),
                                    style: const TextStyle(
                                        color: Colors.black54),
                                  ),
                      ),
                    );
                  },
                )),
          );
        },
      ),
    );
  }
}
