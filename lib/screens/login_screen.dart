import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/auth/auth.dart';
import 'package:we_chat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }



  @override
  Widget build(BuildContext context) {

    final mq = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to We Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            top: mq.height * .15,
            width: mq.width * 0.5,
            right: _isAnimate ? mq.width * 0.25 : -mq.width * .5,
            child: Image.asset(
              'assets/images/we_chat.png',
            ),
          ),
          Positioned(
            height: mq.height * .07,
            bottom: mq.height * .15,
            width: mq.width * 0.7,
            left: mq.width * 0.15,
            child: ChangeNotifierProvider(
                create: (_) => Auth(),
                child: Consumer<Auth>(
                  builder: (context, provider, child) {
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade200,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7))),
                      onPressed: () {
                        provider.setLoading(true);
                        provider.signInWithGoogle(context);
                      },
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: mq.height * 0.03,
                      ),
                      label: provider.loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : RichText(
                              text: const TextSpan(children: [
                              TextSpan(text: " Login with "),
                              TextSpan(
                                  text: "Google",
                                  style: TextStyle(fontWeight: FontWeight.w500))
                            ])),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }


}
