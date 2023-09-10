 import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils{


  static showToast(String mesg){
   Fluttertoast.showToast(msg: mesg);
  }
 }