import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 77, 168, 124)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.green.shade300,
                blurRadius: 8,
                spreadRadius: 3,
                offset: Offset(2, -2)),
          ]),
    );
  }
}
