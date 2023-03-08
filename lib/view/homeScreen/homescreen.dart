import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photosharing/view/homeScreen/ownerDetails/ownerDetails.dart';
import 'package:photosharing/view/homeScreen/profile_screen/profile_screen.dart';
import 'package:photosharing/view/homeScreen/search_post/search_post.dart';
import 'package:photosharing/view/login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  String? profileImage;
  String? myName;
  String? imageUrl;

  File? imageFile;
  String changeTitle = 'Grid View';
  bool checkView = false;

  Widget listViewWidget(String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.green,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  colors: [Colors.green, Colors.white],
                  stops: [0.1, 0.2])),
          padding: EdgeInsets.all(5),
          child: Column(children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OwnerDetails(
                    docId: docId,
                    img: img,
                    userImg: userImg,
                    name: name,
                    date: date,
                    userId: userId,
                    downloads: downloads,
                  ),
                ));
              },
              child: Image.network(
                img,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Row(children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 35,
                  backgroundImage: NetworkImage(userImg),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      DateFormat('dd MMMM, yyyy - hh:mm a')
                          .format(date)
                          .toString(),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ]),
            )
          ]),
        ),
      ),
    );
  }

  Widget gridViewWidget(String docId, String img, String userImg, String name,
      DateTime date, String userId, int downloads) {
    return GridView.count(
      crossAxisCount: 1,
      primary: false,
      padding: EdgeInsets.all(6),
      crossAxisSpacing: 1,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              //create ImageOwner
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OwnerDetails(
                    docId: docId,
                    img: img,
                    userImg: userImg,
                    name: name,
                    date: date,
                    userId: userId,
                    downloads: downloads),
              ));
            },
            child: Center(
              child: Image.network(
                img,
                fit: BoxFit.fill,
              ),
            ),
          ),
        )
      ],
    );
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
        imageFile = File(croppedImage.path);
      });
    }
  }

  void readUserInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) async {
      profileImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }

  void uploadImage() async {
    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Please Select an Image");
      return;
    }
    try {
      final reference = FirebaseStorage.instance
          .ref()
          .child('userImages')
          .child(DateTime.now().toString() + '.jpg');
      await reference.putFile(imageFile!);
      imageUrl = await reference.getDownloadURL();
      FirebaseFirestore.instance
          .collection('wallpaper')
          .doc(DateTime.now().toString())
          .set({
        'id': _auth.currentUser!.uid,
        'userImage': profileImage,
        'name': myName,
        'email': _auth.currentUser!.email,
        'feedImage': imageUrl,
        'downloads': 0,
        'createdAt': DateTime.now()
      });
      Navigator.canPop(context) ? Navigator.pop(context) : null;
      imageFile = null;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            margin: EdgeInsets.all(8),
            child: FloatingActionButton(
                heroTag: '1',
                onPressed: () {
                  _showImageDialog();
                },
                backgroundColor: Colors.lightGreen,
                child: Icon(Icons.camera_enhance)),
          ),
          Container(
            margin: EdgeInsets.all(8),
            child: FloatingActionButton(
                heroTag: '2',
                onPressed: () {
                  //upload image
                  uploadImage();
                },
                backgroundColor: Colors.lightGreen,
                child: Icon(Icons.cloud_upload)),
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfileScreen(),
            ));
          },
        ),
        title: GestureDetector(
          onTap: () {
            setState(() {
              changeTitle = 'List View';
              checkView = true;
            });
          },
          onDoubleTap: () {
            setState(() {
              changeTitle = 'Grid View';
              checkView = false;
            });
          },
          child: Text(
            changeTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPost(),
              ));
            },
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              _auth.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
            },
            child: Icon(Icons.logout),
          ),
          SizedBox(
            width: 5,
          ),
        ],
        flexibleSpace: Container(
          height: 150,
          color: Colors.green,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wallpaper')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            var data = snapshot.data!.docs;
            if (data.isNotEmpty) {
              if (checkView == true) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    print(data[index]['downloads']);

                    return listViewWidget(
                      data[index].id,
                      data[index]['feedImage'],
                      data[index]['userImage'],
                      data[index]['name'],
                      data[index]['createdAt'].toDate(),
                      data[index]['id'],
                      data[index]['downloads'],
                    );
                  },
                );
              } else {
                return GridView.builder(
                    itemCount: data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: ((context, index) {
                      return gridViewWidget(
                        data[index].id,
                        data[index]['feedImage'],
                        data[index]['userImage'],
                        data[index]['name'],
                        data[index]['createdAt'].toDate(),
                        data[index]['id'],
                        data[index]['downloads'],
                      );
                    }));
              }
            }
          }
          return Center(
            child: Text(
              "Something Went Wrong",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
