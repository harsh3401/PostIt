import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:post_it/views/postDetail.dart';
import 'package:random_string/random_string.dart';
import '/services/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../services/Validate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  void insertData() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    DatabaseService databaseService = new DatabaseService();
    User? currentuser = _auth.currentUser;
    Stream stream;
    stream = await databaseService.getPostData();

    setState(() {
      PostStream = stream;
    });
  }

  @override
  void initState() {
    insertData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                                    postId: snapshot.data.docs[index].id)));
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage('assets/stack.jpg'),
                              ),
                              title: Text(
                                snapshot.data.docs[index].data()['Question'],
                              ),
                              subtitle: Text(
                                'Timestamp',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                snapshot.data.docs[index].data()['Description'],
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  onPressed: () {
                                    // Perform some action
                                  },
                                  child: const Icon(Icons.comment),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Colors.black),
                                  onPressed: () {
                                    // Perform some action
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
                onPressed: () {},
                icon: Icon(Icons.account_circle),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.forum),
                iconSize: 30.0,
              )
            ],
          ),
        ),
        height: 60.0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showDialog,
        child: Text(
          '+',
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _showDialog() {
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
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      DatabaseService database = new DatabaseService();
                      FirebaseAuth _auth = FirebaseAuth.instance;
                      User? currentuser = _auth.currentUser;
                      Map<String, dynamic> newPost = {
                        "Question": question,
                        "Description": desc,
                        "Author": currentuser!.uid,
                        "imgURL": imgURL,
                        "created": Timestamp.now(),
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
                    }
                  },
                  child: Text("Publish"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                      padding: MaterialStateProperty.all(EdgeInsets.all(10.0))),
                ),
                sampleImage == null ? Text('Select Image') : enableUpload(),
                TextButton(onPressed: getImage, child: Text('Select Image'))
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

  Widget enableUpload() {
    var randomno = Random(25);
    return Container(
      child: Column(children: [
        Image.file(
          File(sampleImage!.path),
          height: 250.0,
          width: 350.0,
        ),
        ElevatedButton(
          onPressed: () async {
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
          },
          child: Text('Upload'),
          style: ElevatedButton.styleFrom(
              elevation: 2,
              primary: Colors.redAccent,
              textStyle: TextStyle(fontSize: 3, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
