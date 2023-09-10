import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/screens/login_screen.dart';
import 'package:we_chat/utils/utils.dart';
import '../screens/home_screen.dart';

class Auth with ChangeNotifier {

   bool shouldUserExist = false;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;

  static User get user => auth.currentUser!;

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
                Utils.showToast(error.toString()),
                print("StackTrace ${stackTrace}"),
              });
    } catch (e) {
      setLoading(false);
      Utils.showToast(e.toString());
    }
  }

  void logOut(BuildContext context) async {
    try {
      auth.signOut();
      await GoogleSignIn()
          .signOut()
          .then((value) => {
                Utils.showToast("Sign Out"),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()))
              })
          .onError((error, stackTrace) => {
                Utils.showToast(error.toString()),
              });
    } catch (e) {
      Utils.showToast(e.toString());
    }
  }

  // for checking if user exist or not?
  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for creating new user

  static Future<void> createUser()async{
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(email: user.email.toString(), name: user.displayName.toString(), id: user.uid,
        image: user.photoURL.toString(), about: "Hey, I'm using We chat",
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }
}
