import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:post_it/views/favourites.dart';
import 'package:post_it/views/postDetail.dart';
import 'package:post_it/views/publish.dart';
import 'package:random_string/random_string.dart';
import '/services/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../services/Validate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:post_it/views/profile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({Key? key}) : super(key: key);

  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  XFile? sampleImage;

  Future getImage() async {
    var tempImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  Stream? PostStream;
  String? question;
  String? desc;
  String? imgURL;
  bool isLoading = true;
  bool isUpLoading = false;
  void insertData() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseService databaseService = new DatabaseService();
    User? currentuser = _auth.currentUser;
    Stream stream;
    stream = await databaseService.getPostData();

    setState(() {
      PostStream = stream;
    });

    setState(() {
      isLoading = false;
    });
  }

  String formatDate(Timestamp timestamp) {
    DateTime myDateTime = (timestamp).toDate();
    DateFormat('yyyy-MM-dd – kk:mm').format(myDateTime);
    String result = myDateTime.toString();
    return result.substring(0, result.length - 7);
  }

  @override
  void initState() {
    insertData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: SpinKitRotatingCircle(
              color: Colors.white,
              size: 50.0,
            ))
          : SafeArea(
              child: StreamBuilder(
              stream: PostStream,
              builder: (context, AsyncSnapshot snapshot) {
                return snapshot.data == null
                    ? Container()
                    : ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostDetail(
                                          postId: snapshot.data.docs[index].id,
                                          postimageurl: snapshot
                                              .data.docs[index]
                                              .data()['imgURL'])));
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  ListTile(
                                    //'assets/stack.jpg' ,
                                    leading: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot
                                            .data.docs[index]
                                            .data()['authorimageurl'])),
                                    title: Text(
                                      snapshot.data.docs[index]
                                          .data()['Question'],
                                    ),
                                    subtitle: Text(
                                      snapshot.data.docs[index]
                                          .data()['created']
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: Text(
                                      snapshot.data.docs[index]
                                          .data()['Description'],
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.black),
                                        onPressed: () async {
                                          FirebaseFirestore _firestore =
                                              FirebaseFirestore.instance;
                                          FirebaseAuth _auth =
                                              FirebaseAuth.instance;
                                          Map<String, dynamic> cuser = {};
                                          await _firestore
                                              .collection("users")
                                              .doc(_auth.currentUser!.uid)
                                              .get()
                                              .then((value) =>
                                                  {cuser = value.data()!});

                                          String postid =
                                              snapshot.data.docs[index].id;
                                          String postquestion = snapshot
                                              .data.docs[index]
                                              .data()['Question'];
                                          dynamic pass = "lajfldj";
                                          List<dynamic> templist =
                                              cuser['favourites'];
                                          templist.add(
                                              "(${postid})${postquestion}");
                                          print(templist);
                                          Map<String, dynamic> newData = {
                                            'name': cuser['name'],
                                            'email': cuser['email'],
                                            'image': cuser['image'],
                                            'favourites': templist,
                                            'posts': cuser['posts'],
                                            'answers': cuser['answers'],
                                          };
                                          print(newData);
                                          await _firestore
                                              .collection("users")
                                              .doc(_auth.currentUser!.uid)
                                              .update(newData);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FavouritesPosts()));
                                        },
                                        child: const Icon(Icons.favorite),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
              },
            )),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Home'),
      ),
      bottomNavigationBar: SizedBox(
        child: BottomAppBar(
          color: Colors.red,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Profile()));
                },
                icon: Icon(Icons.account_circle),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.home),
                color: Colors.grey,
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavouritesPosts()));
                },
                icon: Icon(Icons.favorite_outline),
                iconSize: 30.0,
              )
            ],
          ),
        ),
        height: 60.0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Publish()));
        },
        child: Text(
          '+',
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
