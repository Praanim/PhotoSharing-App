import 'package:flutter/material.dart';

class AccountCheck extends StatelessWidget {
  final bool login;
  final VoidCallback press;
  const AccountCheck({
    Key? key,
    required this.login,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        height: 40,
      ),
      Text(
        login ? "Don't have an Account..?" : "Already have an Account..?",
        style: TextStyle(
            fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
      ),
      SizedBox(
        width: 5,
      ),
      GestureDetector(
        onTap: press,
        child: Text(
          login ? "Create Account" : "Log In",
          style: TextStyle(
              fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    ]);
  }
}
