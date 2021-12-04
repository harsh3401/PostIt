import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:post_it/services/Database.dart';
import 'package:post_it/views/favourites.dart';
import 'package:post_it/views/login.dart';
import 'package:post_it/views/mainpage.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? _image;
  String? imgURL;
  int? ansCount;
  int? postCount;
  String userImage = "";
  _imgFromCamera() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image!;
    });
  }

  getUserData() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Map<String, dynamic> curruser = {};
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {curruser = value.data()!});

    setState(() {
      ansCount = curruser['answers'];
      postCount = curruser['posts'];
      userImage = curruser['image'];
    });
    print(userImage);
  }

  _imgFromGallery() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image!;
    });
  }

  uploadImage() async {
    var randomno = Random();
    FirebaseStorage storage = FirebaseStorage.instance;
    String val = randomno.nextInt(5000).toString();
    print('random val$val');
    Reference ref = storage.ref().child('profilepic/${val}.jpg');

    TaskSnapshot uploadTask = await ref.putFile(File(_image!.path));

    await storage.ref('profilepic/$val.jpg').getDownloadURL().then((data) => {
          if (this.mounted)
            {
              setState(() {
                imgURL = data;
              }),
            }
        });
    print('Uploaded the image to storage & auth');
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseService databaseServices = new DatabaseService();
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _auth.currentUser!.updatePhotoURL(imgURL);
    Map<String, dynamic> cuser = {};
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {cuser = value.data()!});
    Map<String, dynamic> newData = {
      'name': cuser['name'],
      'email': cuser['email'],
      'image': imgURL,
      'favourites': cuser['favourites'],
      'posts': cuser['posts'],
      'answers': cuser['answers'],
    };
    print(newData);
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .update(newData);
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () async {
                        await _imgFromGallery();
                        Navigator.of(context).pop();
                        uploadImage();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      await _imgFromCamera();
                      Navigator.of(context).pop();
                      uploadImage();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        child: BottomAppBar(
          color: Colors.red,
          child: Row(
            children: [
              IconButton(
                highlightColor: Colors.black,
                onPressed: () {},
                icon: Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                ),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Mainpage()));
                },
                icon: Icon(Icons.home),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavouritesPosts()));
                },
                icon: Icon(Icons.favorite_border_outlined),
                iconSize: 30.0,
              )
            ],
          ),
        ),
        height: 60.0,
      ),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              FirebaseAuth _auth = FirebaseAuth.instance;
              await _auth.signOut();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Logged out successfully!',
                    style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.red,
                elevation: 10,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(10),
              ));
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            } //logout code,
            ),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('Your Profile'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.red, Colors.black],
                    ),
                  ),
                  child: Column(children: [
                    SizedBox(
                      height: 110.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.black,
                          child: userImage != ""
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image(
                                    image: NetworkImage(userImage),
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.fitHeight,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(50)),
                                  width: 100,
                                  height: 100,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                        FirebaseAuth.instance.currentUser!.displayName
                            .toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.email.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    )
                  ]),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                      child: Card(
                          margin: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                          child: Container(
                              width: 310.0,
                              height: 220.0,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    Text(
                                      "User Analytics",
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey[300],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.help_center,
                                          color: Colors.blueAccent[400],
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "No of questions asked",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            Text(
                                              postCount.toString(),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.grey[400],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.question_answer,
                                          color: Colors.red,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "No of answers given",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            Text(
                                              ansCount.toString(),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.grey[400],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
