import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photosharing/view/homeScreen/homescreen.dart';
import 'package:photosharing/view/login/account_check/account_check.dart';
import 'package:photosharing/view/login/forgotPassword/forgotPassword.dart';
import 'package:photosharing/view/login/signup/signUp_screen.dart';
import 'package:photosharing/view/widgets/button_login.dart';
import 'package:photosharing/view/widgets/inputfield.dart';

class Credentials extends StatefulWidget {
  const Credentials({Key? key}) : super(key: key);

  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  UserCredential? result;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
              child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/logo1.png'),
                  backgroundColor: Colors.green.shade300)),
        ),
        SizedBox(
          height: 15,
        ),
        InputField(
            hintText: "Enter Email",
            icon: Icons.supervised_user_circle,
            obscureText: false,
            editingController: usernameController),
        InputField(
            hintText: "Enter Password",
            icon: Icons.lock,
            obscureText: true,
            editingController: passwordController),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ));
              },
              child: Text(
                "Forgot Password ..?",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                    fontFamily: 'MyFont'),
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Center(
          child: LoginButton(
            text: "Login",
            press: () async {
              //login hai kta ho
              try {
                result = await auth.signInWithEmailAndPassword(
                    email: usernameController.text.trim().toLowerCase(),
                    password: passwordController.text.trim());
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
              } on FirebaseAuthException catch (e) {
                Fluttertoast.showToast(msg: e.toString());
              }
            },
          ),
        ),
        AccountCheck(
            login: true,
            press: () {
              //navigate to sign up page
              Navigator.push(
                  context, MaterialPageRoute(builder: ((context) => SignUp())));
            })
      ],
    );
  }
}
