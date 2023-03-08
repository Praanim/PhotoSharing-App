import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:photosharing/view/widgets/button_login.dart';

class OwnerDetails extends StatefulWidget {
  final String docId;
  final String img;
  final String userImg;
  final String name;
  final DateTime date;
  final String userId;
  int? downloads;
  OwnerDetails({
    Key? key,
    required this.docId,
    required this.img,
    required this.userImg,
    required this.name,
    required this.date,
    required this.userId,
    this.downloads,
  }) : super(key: key);

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> {
  int? total;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Go Back",
          style: TextStyle(color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.green,
                  image: DecorationImage(
                      image: NetworkImage(widget.img), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 2.0, color: Colors.green)),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Owner Information",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2.0, color: Colors.green),
                      image: DecorationImage(
                          image: NetworkImage(widget.userImg),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Updated By :",
                      style: TextStyle(color: Colors.green),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.name,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat("dd MMMM,yyyy - hh:mm a")
                      .format(widget.date)
                      .toString(),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () async {
                    try {
                      print(widget.img);
                      var imageId =
                          await ImageDownloader.downloadImage(widget.img);
                      if (imageId == null) {
                        print("Hello World");
                        return;
                      }

                      Fluttertoast.showToast(msg: "Image Saved To Gallery");
                      total = (widget.downloads! + 1);

                      FirebaseFirestore.instance
                          .collection('wallpaper')
                          .doc(widget.docId)
                          .update({'downloads': total}).then((value) {
                        Navigator.pop(context);
                      });
                    } on PlatformException catch (error) {
                      print(error);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 40,
                        color: Colors.green,
                      ),
                      Text(
                        ' ' + widget.downloads.toString(),
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                FirebaseAuth.instance.currentUser!.uid == widget.userId
                    ? LoginButton(
                        text: "Delete",
                        press: () async {
                          FirebaseFirestore.instance
                              .collection('wallpaper')
                              .doc(widget.docId)
                              .delete()
                              .then((value) {
                            Navigator.pop(context);
                          });
                        })
                    : Container()
              ],
            ))
          ],
        ),
      ),
    );
  }
}
