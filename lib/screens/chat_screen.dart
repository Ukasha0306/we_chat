import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/model/message_model.dart';
import 'package:we_chat/screens/view_profile_screen.dart';
import 'package:we_chat/utils/my_date.dart';
import 'package:we_chat/widget/message_card.dart';
import '../auth/auth.dart';
import '../auth/profile_controller.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

final _textController = TextEditingController();
List<MessageModel> _list = [];
bool _showEmoji = false;

bool isLoading = false;

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileController>(context, listen: false);
    final mq = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ChangeNotifierProvider(
                    create: (_) => Auth(),
                    child: Consumer<Auth>(
                      builder: (context, provider, child) {
                        return StreamBuilder(
                          stream: provider.getAllMessage(widget.user),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.connectionState ==
                                    ConnectionState.none) {
                              return const SizedBox();
                            } else if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text(
                                "Say Hi 👋",
                                style: TextStyle(fontSize: 24),
                              )); // No data available message
                            } else {
                              final data = snapshot.data!.docs;
                              _list = data
                                      .map((e) =>
                                          MessageModel.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              return ListView.builder(
                                  reverse: true,
                                  padding:
                                      EdgeInsets.only(top: mq.height * 0.01),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    // return const ChatUserCard();
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                  });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              if(provider.loading)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: CircularProgressIndicator(strokeWidth: 2,),
              ),),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                          columns: 8,
                          bgColor: Colors.white,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0)),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    final mq = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProfileScreen(
              user: widget.user,
            ),
          ),
        );
      },
      child: ChangeNotifierProvider(
        create: (_) => Auth(),
        child: Consumer<Auth>(
          builder: (context, provider, child) {
            return StreamBuilder(
              stream: provider.getSpecificUserInfo(widget.user),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!.docs;
                  final list =
                      data.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                      ClipOval(
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(20),
                          child: CachedNetworkImage(
                            height: mq.height * 0.10,
                            width: mq.width * 0.10,
                            imageUrl: list.isNotEmpty
                                ? list[0].image
                                : widget.user.image,
                            errorWidget: (context, ulr, error) =>
                                const CircleAvatar(
                              child: Icon(
                                Icons.person,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list.isNotEmpty ? list[0].name : widget.user.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              list.isNotEmpty
                                  ? list[0].isOnline
                                      ? 'Online'
                                      : MyDate.getLastActiveTime(
                                          context: context,
                                          lastActive: list[0].lastActive)
                                  : MyDate.getLastActiveTime(
                                      context: context,
                                      lastActive: widget.user.lastActive),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _chatInput() {
    final provider = Provider.of<ProfileController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.deepPurple.shade50,
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      size: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    cursorColor: Colors.black54,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type Somethings...'),
                  )),
                  IconButton(
                    onPressed: ()  {
                       provider.pickCameraImage(context);
                       provider.sendChatImage(widget.user,context);
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      provider.pickMultipleImage(widget.user, context) ;

                    },
                    icon: const Icon(
                      Icons.image,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          ChangeNotifierProvider(
            create: (_) => Auth(),
            child: Consumer<Auth>(
              builder: (context, provider, child) {
                return MaterialButton(
                  minWidth: 0,
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      if(_list.isEmpty) {
                        // on first message send add user to my_user collection of chat user
                        provider.sendFirstMessage(
                            widget.user, _textController.text, Type.text,context );
                      }
                        else{
                        provider.sendMessage(widget.user, _textController.text, Type.text, context);

                      }
                      _textController.clear();
                      }

                  },
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.only(
                      top: 10, right: 5, bottom: 10, left: 10),
                  color: Colors.white,
                  child: const Center(
                      child: Icon(
                    Icons.send,
                    size: 28,
                  )),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
