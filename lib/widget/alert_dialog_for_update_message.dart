import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/model/message_model.dart';
import '../auth/auth.dart';


void updateDialogForUpdateMessage(BuildContext context, MessageModel messageModel) {
  String updatedMesg = messageModel.msg;
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        title: const Row(
          children: [
            Icon(
              Icons.message,
              size: 24,
              color: Colors.deepPurple,
            ),
            SizedBox(
              width: 15,
            ),
            Text('Update Message',style: TextStyle(color: Colors.deepPurple, fontSize: 18),),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMesg,
          maxLines: null,
          onChanged: (value) => updatedMesg = value,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
              )),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 18),),
          ),
          ChangeNotifierProvider(
            create: (_)=>Auth(),
            child: Consumer<Auth>(
              builder: (context, provider, child){
                return MaterialButton(
                  onPressed: () {
                    provider.updateMessage(messageModel, updatedMesg);
                    Navigator.pop(context);
                  },
                  child: const Text("Update", style: TextStyle(color: Colors.deepPurple, fontSize: 18),),
                );
              },
            ),
          )
        ],
      ));
}