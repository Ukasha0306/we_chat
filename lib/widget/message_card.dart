import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/utils/my_date.dart';
import 'package:we_chat/widget/alert_dialog_for_update_message.dart';
import '../auth/auth.dart';
import '../model/message_model.dart';
import '../utils/dialogs.dart';
import 'option_items.dart';

class MessageCard extends StatefulWidget {
  final MessageModel message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Auth(),
      child: Consumer<Auth>(
        builder: (context, provider, child) {
          bool isMe = provider.user.uid == widget.message.formId;
          return InkWell(
            onLongPress: () {
              _showBottomSheet(isMe);
            },
            child: isMe ? _purpleMessage() : _tealMessage(),
          );
        },
      ),
    );
  }

  // our message
  Widget _purpleMessage() {
    final mq = MediaQuery.sizeOf(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.02,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_outlined,
                size: 16,
                color: Colors.blue,
              ),
            SizedBox(
              width: mq.width * 0.03,
            ),
            Text(
              MyDate.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.01
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.05, vertical: mq.height * 0.02),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: Colors.deepPurple,
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                      imageUrl: widget.message.msg,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // sender message
  Widget _tealMessage() {
    final mq = MediaQuery.sizeOf(context);

    return Consumer<Auth>(
      builder: (context, provider, child) {
        if (widget.message.read.isEmpty) {
          provider.updateMessageReadStatus(widget.message);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * 0.01
                    : mq.width * 0.04),
                margin: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.05,
                  vertical: mq.height * 0.02,
                ),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                  ),
                  // border: Border.all(
                  //   color: Colors.teal,
                  // ),
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                          ),
                          imageUrl: widget.message.msg,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: mq.width * 0.03),
              child: Text(
                MyDate.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(bool isMe) {
    final mq = MediaQuery.sizeOf(context);
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),),),
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.04, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12)),
              ),
              widget.message.type == Type.text
                  ? OptionItems(
                      icon: Icon(
                        Icons.copy,
                        size: 26,
                        color: Colors.deepPurple.shade400,
                      ),
                      title: 'Copy Text',
                      onPress: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showToast("Message Copied!");
                        });
                      })
                  : OptionItems(
                      icon: Icon(
                        Icons.download_outlined,
                        size: 26,
                        color: Colors.deepPurple.shade400,
                      ),
                      title: 'Save Image',
                      onPress: () {
                        saveImage();
                        Navigator.pop(context);
                      }),
              if (widget.message.type == Type.text && isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * 0.08,
                  indent: mq.width * 0.08,
                ),
              if (widget.message.type == Type.text && isMe)
                ChangeNotifierProvider(
                  create: (_) => Auth(),
                  child: Consumer<Auth>(
                    builder: (context, provider, child) {
                      return OptionItems(
                          icon: Icon(
                            Icons.edit,
                            size: 26,
                            color: Colors.deepPurple.shade400,
                          ),
                          title: 'Edit Message',
                          onPress: () {
                            Navigator.pop(context);
                            updateDialogForUpdateMessage(
                                context, widget.message);
                            // Navigator.pop(context);
                          });
                    },
                  ),
                ),
              if (widget.message.type == Type.text && isMe)
                ChangeNotifierProvider(
                  create: (_) => Auth(),
                  child: Consumer<Auth>(
                    builder: (context, provider, child) {
                      return OptionItems(
                          icon: const Icon(
                            Icons.delete_forever,
                            size: 26,
                            color: Colors.red,
                          ),
                          title: 'Delete Message',
                          onPress: () {
                            provider.deleteMessage(widget.message);
                            Navigator.pop(context);
                            Dialogs.showToast("Message deleted");
                          });
                    },
                  ),
                ),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 0.08,
                indent: mq.width * 0.08,
              ),
              OptionItems(
                  icon: Icon(
                    Icons.remove_red_eye,
                    size: 26,
                    color: Colors.deepPurple.shade400,
                  ),
                  title:
                      'Sent At ${MyDate.getMessageTime(context: context, time: widget.message.sent)}',
                  onPress: () {}),
              OptionItems(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    size: 26,
                    color: Colors.red,
                  ),
                  title: widget.message.read.isEmpty
                      ? 'Read At : Not seen yet'
                      : 'Read At ${MyDate.getMessageTime(context: context, time: widget.message.read)}',
                  onPress: () {}),
            ],
          );
        });
  }

  void saveImage() async {
    try {
      Response response = await get(Uri.parse(widget.message.msg));
      if (response.statusCode == 200) {
        // Convert the response body to UInt8List
        Uint8List uInt8List = response.bodyBytes;

        // Get the temporary directory to save the image
        Directory directory = await getTemporaryDirectory();
        String path = '${directory.path}/temp_image.png';

        File imageFile = File(path);
        await imageFile.writeAsBytes(uInt8List);

        await GallerySaver.saveImage(imageFile.path, albumName: 'We Chat')
            .then((success) async {
          await imageFile.delete();
          if (success != null && success) {
            Dialogs.showToast("Image Saved Successfully");
          }
        }).onError((error, stackTrace) {
          Navigator.pop(context);
          if (kDebugMode) {
            print("Error on saving the images $error");
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
  }
}
