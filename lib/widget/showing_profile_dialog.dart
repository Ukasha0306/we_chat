import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/screens/view_profile_screen.dart';

class ShowingProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ShowingProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      backgroundColor: Colors.white.withOpacity(.90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: mq.height * .30,
        width: mq.width * .6,
        child: Stack(
          children: [
            Positioned(
                left: mq.width * 0.06,
                top: mq.height * 0.02,
                width: mq.width * .55,
                child: Text(
                  user.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16),
                )),
            Positioned(
              top: mq.height * 0.07,
              left: mq.width * .16,
              child:  ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: user.image,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,// Specify both width and height for a fixed size// Try using BoxFit.cover
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 3,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ViewProfileScreen(user: user)));
                  },
                  icon: const Icon(
                    Icons.info_outline,
                    size: 30,
                    color: Colors.black54,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
