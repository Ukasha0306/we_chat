import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/widget/chat_user_card.dart';

import '../auth/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("We Chat"),
        leading: const Icon(Icons.home),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          ChangeNotifierProvider(
            create: (_) => Auth(),
            child: Consumer<Auth>(
              builder: (context, provider, child) {
                return IconButton(
                  onPressed: () {
                    provider.logOut(context);
                  },
                  icon: const Icon(Icons.more_vert),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
          stream: Auth.firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No data available",
                  style: TextStyle(fontSize: 22),
                ),
              ); // No data available message
            } else {
              final data = snapshot.data!.docs;
              if (kDebugMode) {
                print("Data ${data.last.data()}");
              }
              list = data.map((e) => ChatUser.fromJson(e.data())).toList();

              return ListView.builder(
                  padding: EdgeInsets.only(top: mq.height * 0.01),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    // return const ChatUserCard();
                    return ChatUserCard(user: list[index]);
                  });
            }
          }),
    );
  }
}
