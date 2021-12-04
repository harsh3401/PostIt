import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:post_it/services/Database.dart';
import 'package:post_it/services/Validate.dart';
import 'package:random_string/random_string.dart';

class Publish extends StatefulWidget {
  Publish({Key? key}) : super(key: key);

  @override
  _PublishState createState() => _PublishState();
}

class _PublishState extends State<Publish> {
  String? question;
  String? desc;
  String? imgURL;
  bool isLoading = true;
  bool isUpLoading = false;
  XFile? sampleImage;
  final _formKey = GlobalKey<FormState>();
  Future getImage() async {
    var tempImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  String formatDate(Timestamp timestamp) {
    DateTime myDateTime = (timestamp).toDate();
    DateFormat('yyyy-MM-dd – kk:mm').format(myDateTime);
    String result = myDateTime.toString();
    return result.substring(0, result.length - 7);
  }

  Widget enableUpload() {
    var randomno = Random(25);
    return Container(
      child: Column(children: [
        Image.file(
          File(sampleImage!.path),
          height: 250.0,
          width: 250.0,
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              isUpLoading = true;
            });
            String val = randomno.nextInt(5000).toString();
            FirebaseStorage storage = FirebaseStorage.instance;
            Reference ref = storage.ref().child('postpic/${val}.jpg');

            TaskSnapshot uploadTask =
                await ref.putFile(File(sampleImage!.path));

            await storage
                .ref('postpic/${val}.jpg')
                .getDownloadURL()
                .then((data) => {
                      setState(() {
                        imgURL = data;
                      })
                    });
            print('Uploaded the image');
            setState(() {
              isUpLoading = false;
            });
          },
          child: Text('Upload',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          style: ElevatedButton.styleFrom(
              elevation: 2,
              primary: Colors.red,
              textStyle:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  void _showDialog() async {
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Post what is on your mind"),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      question = value;
                    });
                  },
                  validator: (value) {
                    AuthValidation.questionValidator(question: value);
                  },
                  decoration: InputDecoration(
                      labelText: 'Question', icon: Icon(Icons.help_center)),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      desc = value;
                    });
                  },
                  validator: (value) {
                    AuthValidation.descValidator(desc: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.question_answer),
                  ),
                ),
                SizedBox(height: 15),
                TextButton(
                    onPressed: () async {
                      getImage();
                    },
                    child: Text(
                      'Add Image',
                      style: TextStyle(color: Colors.red),
                    )),
                sampleImage == null ? Text('Select an image') : enableUpload(),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      DatabaseService database = new DatabaseService();
                      FirebaseAuth _auth = FirebaseAuth.instance;
                      User? currentuser = _auth.currentUser;
                      Map<String, dynamic> newPost = {
                        "Question": question,
                        "Description": desc,
                        "authorname": currentuser!.displayName,
                        "authorimageurl":
                            'https://www.w3schools.com/howto/img_avatar.png',
                        "imgURL": imgURL,
                        "created": formatDate(Timestamp.now()),
                      };
                      String postId = randomAlphaNumeric(16);

                      await database
                          .createNewPost(newPost, postId)!
                          .then((val) => {
                                print("New post made.."),
                                setState(() {
                                  imgURL = "";
                                  desc = "";
                                  question = "";
                                }),
                              });
                      FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
                        'posts': cuser['posts'] + 1,
                        'answers': cuser['answers'],
                      };
                      print(newData);
                      await _firestore
                          .collection("users")
                          .doc(_auth.currentUser!.uid)
                          .update(newData);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Post made successfully!',
                            style: TextStyle(color: Colors.black)),
                        backgroundColor: Colors.green,
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(10),
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: isUpLoading
                      ? Row(
                          children: [
                            Text("Image upload in progress"),
                            SizedBox(width: 8),
                            SpinKitRotatingCircle(
                              color: Colors.white,
                              size: 50.0,
                            ),
                          ],
                        )
                      : Text("Publish"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      padding: MaterialStateProperty.all(EdgeInsets.all(10.0))),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Post what is on your mind'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    question = value;
                  });
                },
                validator: (value) {
                  AuthValidation.questionValidator(question: value);
                },
                decoration: InputDecoration(
                    labelText: 'Question', icon: Icon(Icons.help_center)),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    desc = value;
                  });
                },
                validator: (value) {
                  AuthValidation.descValidator(desc: value);
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                  icon: Icon(Icons.question_answer),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                  onPressed: () async {
                    getImage();
                  },
                  child: Text(
                    'Add Image',
                    style: TextStyle(color: Colors.red),
                  )),
              sampleImage == null ? Text('Select an image') : enableUpload(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    DatabaseService database = new DatabaseService();
                    FirebaseAuth _auth = FirebaseAuth.instance;
                    User? currentuser = _auth.currentUser;
                    Map<String, dynamic> newPost = {
                      "Question": question,
                      "Description": desc,
                      "authorname": currentuser!.displayName,
                      "authorimageurl":
                          'https://www.w3schools.com/howto/img_avatar.png',
                      "imgURL": imgURL,
                      "created": formatDate(Timestamp.now()),
                    };
                    String postId = randomAlphaNumeric(16);

                    await database
                        .createNewPost(newPost, postId)!
                        .then((val) => {
                              print("New post made.."),
                              setState(() {
                                imgURL = "";
                                desc = "";
                                question = "";
                              }),
                            });
                    FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
                      'posts': cuser['posts'] + 1,
                      'answers': cuser['answers'],
                    };
                    print(newData);
                    await _firestore
                        .collection("users")
                        .doc(_auth.currentUser!.uid)
                        .update(newData);
                  }
                },
                child: isUpLoading
                    ? Row(
                        children: [
                          Text("Image upload in progress"),
                          SizedBox(width: 8),
                          SpinKitRotatingCircle(
                            color: Colors.white,
                            size: 50.0,
                          ),
                        ],
                      )
                    : Text("Publish"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    padding: MaterialStateProperty.all(EdgeInsets.all(10.0))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
