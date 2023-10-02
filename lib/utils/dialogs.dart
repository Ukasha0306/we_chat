import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Dialogs {
  static showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.deepPurple.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }


  static showToast(String mesg) {
    Fluttertoast.showToast(
      msg: mesg,
      fontSize: 16,
    );
  }
}