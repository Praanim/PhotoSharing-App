import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photosharing/view/login/account_check/account_check.dart';
import 'package:photosharing/view/widgets/button_login.dart';
import 'package:photosharing/view/widgets/inputfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.green, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [PHeading(), PCredential()],
          ),
        )),
      ),
    );
  }
}

class PHeading extends StatelessWidget {
  const PHeading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.05,
          ),
          Center(
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                  fontSize: 55,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Myfont'),
            ),
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          Center(
            child: Text("Reset Here",
                style: TextStyle(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class PCredential extends StatelessWidget {
  TextEditingController _emailController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/forget.png',
            width: null,
          ),
          InputField(
              hintText: "Enter Email",
              icon: Icons.email_rounded,
              obscureText: false,
              editingController: _emailController),
          SizedBox(
            height: 10,
          ),
          LoginButton(
              text: "Send Link",
              press: () async {
                try {
                  await _auth.sendPasswordResetEmail(
                      email: _emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        "Password reset email has been sent",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )));
                } on FirebaseAuthException catch (error) {
                  Fluttertoast.showToast(msg: error.toString());
                }
                Navigator.pop(context);
              }),
          SizedBox(
            height: 10,
          ),
          AccountCheck(
              login: false,
              press: () {
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}
