import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/utils/my_date.dart';


class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name, style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.w500),),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Joined On:",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          Text(
            MyDate.getLastMessage(
                context: context, time: widget.user.createdAt, showYear: true),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: mq.height * 0.03,
                width: mq.width,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: widget.user.image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,// Specify both width and height for a fixed size// Try using BoxFit.cover
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),

              SizedBox(
                height: mq.height * 0.02,
              ),
              Text(widget.user.email),
              SizedBox(
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "About:",
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: mq.width * 0.02,
                  ),
                  Text(widget.user.about),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
