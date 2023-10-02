import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/screens/notification_service.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widget/chat_user_card.dart';
import '../auth/auth.dart';
import '../widget/add_chatting_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  final List<ChatUser> _searchList = [];
  bool isSearching = false;
  Auth auth = Auth();
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth.getUserInfo();

    // for updating user active status according to lifeCycle events
    // resume -- active or online
    // pause -- inactive or offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (FirebaseAuth.instance.currentUser != null) {
        if (message.toString().contains('resume')) {
          auth.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          auth.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & and back button is pressed then close search
        // or else simple close the current screen on back button click
        onWillPop: () {
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
              title: isSearching
                  ? TextField(
                      autofocus: true,
                      style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                      decoration: const InputDecoration(
                        hintText: 'Name, Email ......',
                        border: InputBorder.none,
                      ),
                      // search logic
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : const Text("We Chat"),
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.black,
                size: 20,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                  icon: Icon(
                    isSearching ? Icons.cancel_outlined : Icons.search_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                  user: Auth.isMe,
                                )));
                  },
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                )
              ]),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () {
                addUserForChatting(context);
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: ChangeNotifierProvider(
            create: (_) => Auth(),
            child: Consumer<Auth>(
              builder: (context, provider, child) {
                // get id of only known users
                return StreamBuilder(
                    stream: provider.getMyUserId(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2,));
                      }
                      else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "Add User",
                            style: TextStyle(fontSize: 22),
                          ),
                        );
                      }
                        return StreamBuilder(
                          stream: provider.getAllUserInfo(snapshot.data!.docs.map((e) => e.id).toList() ?? []),
                          // get only those user who's ids are provided
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting ||
                                snapshot.connectionState == ConnectionState.none) {
                              return const Center(child: CircularProgressIndicator());
                             } else {
                              final data = snapshot.data!.docs;
                                log("Data ${data.map((e) => e.data()).toList()}");
                              _list = data
                                  .map((e) => ChatUser.fromJson(e.data()))
                                  .toList();

                              return ListView.builder(
                                  padding: EdgeInsets.only(
                                      top: mq.height * 0.01),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                  isSearching ? _searchList.length : _list
                                      .length,
                                  itemBuilder: (context, index) {
                                    // return const ChatUserCard();
                                    return ChatUserCard(
                                        user: isSearching
                                            ? _searchList[index]
                                            : _list[index]);
                                  });
                            }
                          });
                    });
              },
            ),
          ),
        ),
      ),
    );
  }
}
