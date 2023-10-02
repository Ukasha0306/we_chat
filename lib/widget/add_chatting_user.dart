import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth.dart';
import '../utils/dialogs.dart';

void addUserForChatting(BuildContext context) {
  String email = '';
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        title: const Row(
          children: [
            Icon(
              Icons.email,
              size: 24,
              color: Colors.deepPurple,
            ),
            SizedBox(
              width: 15,
            ),
            Text('Add Email',style: TextStyle(color: Colors.deepPurple, fontSize: 18),),
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email),
            hintText: 'Email Id',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),

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
              builder: (_, provider, child){
                return MaterialButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    if(email.isNotEmpty){
                     await provider.addChatUser(email).then((value) {
                       if(!value){
                         Dialogs.showSnackBar(context, "User does not Exists!");
                       }
                     });
                    }
                  },
                  child: const Text("Add", style: TextStyle(color: Colors.deepPurple, fontSize: 18),),
                );
              },
            ),
          )
        ],
      ));
}