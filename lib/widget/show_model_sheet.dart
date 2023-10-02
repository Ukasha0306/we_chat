import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/auth/profile_controller.dart';

class ShowModelSheet {
  static void showBottomSheetFunction(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final provider = Provider.of<ProfileController>(context, listen: false);
    showModalBottomSheet(
      backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return ListView(
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            shrinkWrap: true,
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),
               Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            provider.pickCameraImage(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            fixedSize:
                                Size(mq.width * 0.30, mq.height * 0.15),
                            shape: const CircleBorder(),
                          ),
                          child: Image.asset('assets/images/camera.png')),
                      ElevatedButton(
                          onPressed: () {
                             provider.pickGalleryImage(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            fixedSize:
                                Size(mq.width * 0.30, mq.height * 0.15),
                            shape: const CircleBorder(),
                          ),
                          child: Image.asset('assets/images/gallery.png'))
                    ],
               )
            ],
          );
        });
  }
}
