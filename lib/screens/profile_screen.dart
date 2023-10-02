import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/auth/profile_controller.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/widget/round_button.dart';
import '../auth/auth.dart';
import '../widget/show_model_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final _formKey = GlobalKey<FormState>();

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileController>(context, listen: false);
    final mq = MediaQuery.sizeOf(context);
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Screen"),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * 0.03,
                    width: mq.width,
                  ),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: provider.image != null
                              ? Image.file(
                            fit: BoxFit.cover,
                                File(provider.image!.path),
                              )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                      height: 200,
                                      width: 200,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: widget.user.image,
                                      )),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          color: Colors.deepPurple.shade200,
                          shape: const CircleBorder(),
                          onPressed: () {
                            ShowModelSheet.showBottomSheetFunction(context);
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Text(widget.user.email,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (value) => Auth.isMe.name = value ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                  ),
                  SizedBox(
                    height: mq.height * 0.02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (value) => Auth.isMe.about = value ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                        labelText: 'About',
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'about',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                  ),
                  SizedBox(
                    height: mq.height * 0.08,
                  ),
                  RoundButton(title: 'Update', onPress: (){
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      provider.updateUserInfo(widget.user);
                      FocusScope.of(context).unfocus();

                    }
                  }, height: 50,
                    width: 200,
                    borderRadius: 50,
                  ),
                  SizedBox(
                    height: mq.height * 0.05,
                  ),
                  RoundButton(
                      title: 'LogOut',
                      onPress: () {
                        provider.logOut(context);
                      }, height: 50, width: double.infinity,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
