import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final double height;
  final double width;
  final VoidCallback onPress;
  final Color color, textColor;
  final bool loading;
  final double borderRadius;

  const RoundButton({Key? key,
    required this.title,
    required this.onPress,
    this.color=Colors.red,
    this.textColor = Colors.white,
    this.loading = false, required this.height, required this.width,  this.borderRadius =8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: loading ? const Center(child: CircularProgressIndicator(color: Colors.white,)) : Center(child: Text(title, style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16, color: textColor))),
      ),
    );
  }
}