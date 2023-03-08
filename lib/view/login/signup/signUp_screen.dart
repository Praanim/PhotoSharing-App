import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photosharing/view/homeScreen/homescreen.dart';
import 'package:photosharing/view/login/account_check/account_check.dart';
import 'package:photosharing/view/widgets/button_login.dart';
import 'package:photosharing/view/widgets/inputfield.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

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
            children: [
              HeadingText(),
              Credentials(),
            ],
          ),
        )),
      ),
    );
  }
}

class HeadingText extends StatelessWidget {
  const HeadingText({Key? key}) : super(key: key);

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
              "PhotoSharing App",
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
            child: Text("Create Account",
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

class Credentials extends StatefulWidget {
  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController phoneController = TextEditingController(text: '');

  File? imageFile;
  String? imageUrl;

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Please choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Camera")
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFromGallery();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Gallery")
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);

    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
              child: GestureDetector(
            onTap: () {
              _showImageDialog();
            },
            child: CircleAvatar(
                radius: 100,
                backgroundImage: imageFile == null
                    ? AssetImage('assets/images/avatar.png')
                    : Image.file(imageFile!).image,
                backgroundColor: Colors.green.shade300),
          )),
        ),
        InputField(
            hintText: "Enter Username",
            icon: Icons.person,
            obscureText: false,
            editingController: usernameController),
        InputField(
            hintText: "Enter Email",
            icon: Icons.email_rounded,
            obscureText: false,
            editingController: emailController),
        InputField(
            hintText: "Enter Password",
            icon: Icons.lock,
            obscureText: true,
            editingController: passwordController),
        InputField(
            hintText: "Enter Phone Number",
            icon: Icons.lock,
            obscureText: false,
            editingController: phoneController),
        LoginButton(
            text: "Create Account",
            press: () async {
              if (imageFile == null) {
                Fluttertoast.showToast(msg: "Please Select an Image");
                return;
              }
              try {
                final reference = FirebaseStorage.instance
                    .ref()
                    .child('userImages')
                    .child(DateTime.now().toLocal().toString() + '.jpg');

                await reference.putFile(imageFile!);
                imageUrl = await reference.getDownloadURL();

                await _auth.createUserWithEmailAndPassword(
                    email: emailController.text.trim().toLowerCase(),
                    password: passwordController.text.trim().toLowerCase());

                final User? user = _auth.currentUser;
                final _uid = user!.uid;
                FirebaseFirestore.instance.collection('users').doc(_uid).set({
                  'id': _uid,
                  'userImage': imageUrl,
                  'name': usernameController.text,
                  'email': emailController.text,
                  'phoneNumber': phoneController.text,
                  'createdAt': Timestamp.now()
                });
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              } catch (error) {
                Fluttertoast.showToast(msg: error.toString());
                print(error.toString());
              }
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
            }),
        AccountCheck(
            login: false,
            press: () {
              Navigator.pop(context);
            })
      ],
    );
  }
}
