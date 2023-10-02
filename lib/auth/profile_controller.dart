import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/auth/auth.dart';
import '../model/chat_user.dart';
import '../model/message_model.dart';
import '../screens/login_screen.dart';
import '../utils/dialogs.dart';


class ProfileController with ChangeNotifier {
  Auth auth = Auth();

  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  User get user => firebaseAuth.currentUser!;
  final picker = ImagePicker();

  XFile? _image;

  XFile? get image => _image;

  XFile? _multipleImage;

  XFile? get multipleImage => _multipleImage;

  Future pickGalleryImage(BuildContext context) async {
    try {
      final pickedImage =
      await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedImage != null) {
        _image = XFile(pickedImage.path);
        notifyListeners();
        uploadImage();
      }
    } catch (e) {
      print("Error picking gallery image: .......... $e.");
    }
  }

// for picking multiple Images
  Future pickMultipleImage(ChatUser chatUser, BuildContext context) async {
    try {
      final List<XFile> multipleImage = await picker.pickMultiImage(imageQuality: 70);

      for(var i in multipleImage){
        _multipleImage = XFile(i.path);
        notifyListeners();
        sendChatImage(chatUser, context);

      }
    } catch (e) {
      print("Error picking gallery image: .......... $e.");
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedImage =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 70, );
    if (pickedImage != null) {
      _image = XFile(pickedImage.path);
      notifyListeners();
      uploadImage();
    }
  }

  void logOut(BuildContext context) async {
    try {
      firebaseAuth.signOut();
      auth.updateActiveStatus(false);
      await GoogleSignIn()
          .signOut()
          .then((value) =>
      {
        Navigator.pop(context),
        Dialogs.showToast("Sign Out"),
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        ),
      })
          .onError((error, stackTrace) =>
      {
        Dialogs.showToast(error.toString()),
      });
    } catch (e) {
      Dialogs.showToast(e.toString());
    }
  }

  // for update user data

  Future<void> updateUserInfo(ChatUser chatUser) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'name': chatUser.name,
      'about': chatUser.about,
    })
        .then(
          (value) =>
      {
        Dialogs.showToast("Profile Updated Successfully"),
        print("User uid ${user.uid.toString()}"),
      },
    )
        .onError((error, stackTrace) =>
    {
      Dialogs.showToast(error.toString()),
    });
  }

  // upload image to firestore storage

  Future<void> uploadImage() async {
    // getting image file ext

    try{
      setLoading(true);
      final ref = storage.ref().child('profile_picture/${user.uid}');
      UploadTask uploadTask = ref.putFile(File(image!.path).absolute);

      // uploading image

      await Future.value(uploadTask);
      final newUrl = await ref.getDownloadURL();
      firestore
          .collection("users")
          .doc(user.uid)
          .update({
        'image': newUrl.toString(),
      }).then((value) {
        setLoading(false);
      }).onError((error, stackTrace) => Dialogs.showToast(error.toString()),);
    }
    catch(e){
      setLoading(false);
      print(e.toString());
    }
  }


  // send chat image

  Future<void> sendChatImage(ChatUser chatUser, BuildContext context) async {
   try{
     setLoading(true);
     if(multipleImage != null){
       final ref = storage.ref().child(
           'images/${auth.getConversionID(chatUser.id)}/${DateTime
               .now()
               .millisecondsSinceEpoch}');
       UploadTask uploadTask = ref.putFile(File(multipleImage!.path).absolute);

       // uploading image

       await Future.value(uploadTask);
       final imageUrl = await ref.getDownloadURL();
        setLoading(true);
       await auth.sendMessage(chatUser, imageUrl, Type.image,context).then((value) {
         setLoading(false);
       });
     }
     else{
       const Icon(Icons.image, size: 70,);
     }
   }
   catch(e){
     setLoading(false);
     print("Error in sending images $e");
   }

  }
}
