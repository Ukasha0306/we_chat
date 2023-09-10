import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../model/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: ClipOval(

            child: SizedBox.fromSize(
              size:Size.fromRadius(20),
              child: CachedNetworkImage(
                height: mq.height*0.12,
                width: mq.width*0.12,
                imageUrl: widget.user.image,
                errorWidget: (context, ulr, error)=> const CircleAvatar(child: Icon(Icons.person, color: Colors.red,),),
              ),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing:  Container(
            height: mq.height*0.03,
            width: mq.width*0.03,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
