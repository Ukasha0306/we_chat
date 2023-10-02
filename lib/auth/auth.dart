import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/auth/profile_controller.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/model/message_model.dart';
import 'package:we_chat/screens/notification_service.dart';
import '../screens/home_screen.dart';
import '../utils/dialogs.dart';

NotificationService notificationService = NotificationService();

ProfileController profileController = ProfileController();

class Auth with ChangeNotifier {
  bool shouldUserExist = false;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;

  User get user => auth.currentUser!;
  static late ChatUser isMe;

  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void signInWithGoogle(BuildContext context) async {
    setLoading(true);
    try {
      // check user is connected to internet or not
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await auth
          .signInWithCredential(credential)
          .then((user) => {
                setLoading(false),
                shouldUserExist ? userExist() : createUser(),
                debugPrint("user ${user.user}"),
                debugPrint('Addition information ${user.additionalUserInfo}'),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                ),
              })
          .onError((error, stackTrace) => {
                Dialogs.showToast(error.toString()),
                print("StackTrace $stackTrace"),
              });
    } catch (e) {
      setLoading(false);
      Dialogs.showToast(e.toString());
    }
  }

  // for checking if user exist or not?
  Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conservation

  Future<bool> addChatUser(String email) async {
    final addUser = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log("AddUserDocs ${addUser.docs}");

    if (addUser.docs.isNotEmpty && addUser.docs.first.id != user.uid) {
      // user exist
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(addUser.docs.first.id)
          .set({});
      log("AddUserDocsFirstId ${addUser.docs.first.data()}");
      return true;
    } else {
      // user does not exist
      return false;
    }
  }


  // for delete the user from homeScreen
  Future deleteChat(String email, ChatUser chatUser) async {
        await firestore.collection('users').doc(user.uid).collection('my_users').doc(chatUser.id).delete();

    }




  // for creating new user

  Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        email: user.email.toString(),
        name: user.displayName.toString(),
        id: user.uid,
        image: user.photoURL.toString(),
        about: "Hey, I'm using We chat",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '',

    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting current user info
  Future<void> getUserInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        isMe = ChatUser.fromJson(user.data()!);
        await notificationService.getDeviceToken(isMe);
        // for setting user status to active
        updateActiveStatus(true);
        print("My Data ${user.data()}");
      } else {
        await createUser().then((value) => getUserInfo());
      }
    });
  }

  // for getting id's of known users from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all user

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserInfo(
      List<String> userIds) {
    log('\nUserIds: $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        // where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

// useful for getting conservation id

  String getConversionID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

// for getting all message of a specific conservation from firestore database

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(ChatUser user) {
    return firestore
        .collection("chats/${getConversionID(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();

    // chats (collection) ==> conservation_id (doc) ==> messages (collection) ==> message (doc)
  }

  // for getting specific user info
  Stream<QuerySnapshot<Map<String, dynamic>>> getSpecificUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // for sending message

  Future<void> sendMessage(ChatUser chatUser, String mesg, Type type, BuildContext context) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to sent

    final MessageModel message = MessageModel(
        msg: mesg,
        formId: user.uid,
        toId: chatUser.id,
        read: '',
        type: type,
        sent: time);
    final ref =
        firestore.collection("chats/${getConversionID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>notificationService.sendPushNotification(chatUser, type == Type.text ? mesg : 'image', context) );
    //
  }

  // for delete message

  Future<void> deleteMessage(MessageModel messageModel) async {
    await firestore
        .collection('chats/${getConversionID(messageModel.toId)}/messages/')
        .doc(messageModel.sent)
        .delete();

    if (messageModel.type == Type.image) {
      await profileController.storage.refFromURL(messageModel.msg).delete();
    }
  }




  // for addingUser when first message send
  Future<void> sendFirstMessage(

      ChatUser chatUser, String mesg, Type type, BuildContext context) async {
    try{
      await firestore
          .collection('users')
          .doc(chatUser.id)
          .collection("my_users")
          .doc(user.uid)
          .set({}).then((value) => sendMessage(chatUser, mesg, type, context)).onError((error, stackTrace){
            log("Error in sending the message $error");
            log("Error in sending the message $stackTrace");
      });
    }
    catch(e){
      log("Error in sending message $e");
    }
  }




// for update message
  Future<void> updateMessage(
      MessageModel messageModel, String updatedMesg) async {
    await firestore
        .collection('chats/${getConversionID(messageModel.toId)}/messages/')
        .doc(messageModel.sent)
        .update({
      'msg': updatedMesg,
    });

    if (messageModel.type == Type.image) {
      await profileController.storage.refFromURL(messageModel.msg).delete();
    }
  }

  // update read status of message
  Future<void> updateMessageReadStatus(MessageModel message) async {
    firestore
        .collection('chats/${getConversionID(message.formId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific user

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection("chats/${getConversionID(chatUser.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // update online or last active status of user

  Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': isMe.pushToken,
    });
  }
}
