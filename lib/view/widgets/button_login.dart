import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  const LoginButton({
    Key? key,
    required this.text,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                fontFamily: 'MyFont'),
          ),
        ),
        height: 40,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 8,
                spreadRadius: 3,
                offset: Offset(2, 2),
              )
            ],
            borderRadius: BorderRadius.circular(20),
            color: Colors.green.shade300),
      ),
    );
  }
}
