import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photosharing/view/homeScreen/homescreen.dart';
import 'package:photosharing/view/login/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name = 'loading';
  String? email = 'loading';
  String? image =
      'https://imgs.search.brave.com/i7eL5_4G2tBlh2FUQgegEtoDR2V3tRQGuhWhKybZv-I/rs:fit:474:225:1/g:ce/aHR0cHM6Ly90c2U0/Lm1tLmJpbmcubmV0/L3RoP2lkPU9JUC5m/QkRoMDhKTS1kS18w/R1Fmd1F5XzR3SGFI/YSZwaWQ9QXBp';
  String? phoneNo = 'loading';
  File? imageXFile;
  String userNameInput = 'nothing';
  String? userImageUrl;

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      (snapshot) {
        if (snapshot.exists) {
          setState(() {
            name = snapshot.data()!['name'];
            email = snapshot.data()!['email'];
            image = snapshot.data()!['userImage'];
            phoneNo = snapshot.data()!['phoneNumber'];
          });
        }
      },
    );
  }

  Future _updateUserName() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'name': userNameInput});
  }

  _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateUserName();
                  updateProfileNameOnUserExistingPosts();
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen();
                    },
                  ));
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.green),
              )
            ],
            title: Text("Update Your Name Here"),
            content: TextField(
              decoration: InputDecoration(
                hintText: "Type Here",
              ),
              onChanged: (value) {
                setState(() {
                  userNameInput = value;
                });
              },
            ),
          );
        });
  }

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
        imageXFile = File(croppedImage.path);
        _updateImageInFirestore();
      });
    }
  }

  void _updateImageInFirestore() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference reference = fStorage.FirebaseStorage.instance
        .ref()
        .child('userImages')
        .child(fileName);
    fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) async {
      userImageUrl = url;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'userImage': userImageUrl}).whenComplete(() {
      updateProfileImageOnUserExistingPosts();
    });
  }

  updateProfileImageOnUserExistingPosts() async {
    await FirebaseFirestore.instance
        .collection('wallpaper')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      //where vanni query chalako list of documents aaucha for more documentation

      for (int i = 0; i < snapshot.docs.length; i++) {
        String userProfileImageInPost = snapshot.docs[i]['userImage'];

        if (userProfileImageInPost != userImageUrl) {
          FirebaseFirestore.instance
              .collection('wallpaper')
              .doc(snapshot.docs[i]
                  .id) //snapshot ma limited query matra aako cha from line 200
              .update({'userImage': userImageUrl});
        }
      }
    });
  }

  updateProfileNameOnUserExistingPosts() async {
    await FirebaseFirestore.instance
        .collection('wallpaper')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      //where vanni query chalako list of documents aaucha for more documentation

      for (int i = 0; i < snapshot.docs.length; i++) {
        String userProfileImageInPost = snapshot.docs[i]['name'];

        if (userProfileImageInPost != userNameInput) {
          FirebaseFirestore.instance
              .collection('wallpaper')
              .doc(snapshot.docs[i]
                  .id) //snapshot ma limited query matra aako cha from line 200
              .update({'name': userNameInput});
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            "Profile Screen",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        _showImageDialog();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        minRadius: 60,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: imageXFile == null
                              ? NetworkImage(image!)
                              : Image.file(imageXFile!).image,
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Name: ' + name!,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      IconButton(
                          onPressed: () {
                            //display text inoutDialog
                            _displayTextInputDialog(context);
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email: ' + email!,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      IconButton(
                          onPressed: () {
                            //display text inoutDialog
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Phone Number: ' + phoneNo!,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false);
                    },
                    child: Text("Log Out"),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                  ),
                ])));
  }
}
