import 'package:flutter/material.dart';

class OptionItems extends StatelessWidget {
  final Icon icon;
  final String title;
  final VoidCallback onPress;
  const OptionItems(
      {Key? key,
        required this.icon,
        required this.title,
        required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * 0.01,
            bottom: mq.height * 0.02),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
                  '    $title',
                  style: const TextStyle(
                      fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
                ))
          ],
        ),
      ),
    );
  }
}