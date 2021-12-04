import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  final String postimageurl;
  PostDetail({required String this.postId, required String this.postimageurl});
  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  Map<String, dynamic>? Postcontent = {
    "Description": "",
    "Question": "",
    "authorimageurl": "",
    "authorname": "",
    "created": "",
    "imgURL": "",
  };
  Stream ansStream = new Stream.empty();
  String? newAnswer;
  bool isLoading = true;
  DatabaseService databaseServices = new DatabaseService();
  void getPostDetails() async {
    DocumentReference? documentReference;
    try {
      await databaseServices.getPost(widget.postId)!.then((data) => {
            documentReference = data,
          });

      documentReference!.get().then((value) => {
            setState(() {
              Postcontent = value.data();
              print(Postcontent);
            })
          });
    } catch (err) {}
  }

  Future<void> getAnsStream() async {
    Stream stream;
    stream = (await databaseServices.getAllComments(postId: widget.postId))!;
    setState(() {
      ansStream = stream;
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<String> getUsername(String userId) async {
    String name = "harsh";
    await databaseServices.getUser(userId: userId).get().then((value) =>
        {name = value.data()!['name'], print(value.data()!['name'])});

    return name;
  }

  String? getUserImgurl(String userId) {
    String? url;
    databaseServices.getUser(userId: userId).get().then((value) => {
          url = value.data()!['image'],
        });
    return url;
  }

  @override
  void initState() {
    getPostDetails();
    getAnsStream();
    print(FirebaseAuth.instance.currentUser!.displayName);
    super.initState();
  }

  String formatDate(Timestamp timestamp) {
    DateTime myDateTime = (timestamp).toDate();
    DateFormat('yyyy-MM-dd – kk:mm').format(myDateTime);
    String result = myDateTime.toString();
    return result.substring(0, result.length - 7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Question view"),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 0.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    // First child in the Row for the name and the
                    // Release date information.
                    Expanded(
                      // Name and Release date are in the same column
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Question
                          Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              Postcontent!['Question'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                          ),
                          // timestamp

                          Text(
                            Postcontent![
                                'created'], //formatDate(Postcontent!['created']).toString(),
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icon to check added to favorite or not
                  ],
                ),
              ),
              Image(
                image: NetworkImage(widget.postimageurl),
                width: 500.0,
                height: 250.0,
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(100.0, 0.0, 0.0, 0.0),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(60.0, 0.0, 0.0, 0.0),
                    child: new Text(
                      Postcontent!['Description'].toString(),
                      style: TextStyle(color: Colors.grey),
                      softWrap: true,
                    )),
              ),
              CircleAvatar(
                  backgroundImage:
                      NetworkImage(Postcontent!['authorimageurl'])),
              new Text(Postcontent!['authorname']),
              Divider(
                height: 15.0,
                thickness: 3.0,
              ),
              Text('Answers:',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              isLoading
                  ? Center(
                      child: SpinKitRotatingCircle(
                      color: Colors.white,
                      size: 50.0,
                    ))
                  : Container(
                      child: Column(
                      children: [
                        StreamBuilder(
                            stream: ansStream,
                            builder: (context, AsyncSnapshot snapshot) {
                              return snapshot.data == null
                                  ? Container(height: 10.0, width: 10.0)
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: snapshot.data.docs.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                            child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.0, 8.0, 0.0, 8.0),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text(snapshot
                                                    .data.docs[index]
                                                    .data()['authorname']
                                                    .toString()),
                                                subtitle: Text(snapshot
                                                    .data.docs[index]
                                                    .data()['commenttext']
                                                    .toString()),
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      snapshot.data.docs[index]
                                                              .data()[
                                                          'authorimage']),
                                                ),
                                                trailing: Text(
                                                    formatDate(Timestamp.now()),
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                    )),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    40.0, 0.0, 0.0, 0.0),
                                                child: ReplyRender(
                                                    commentId: snapshot
                                                        .data.docs[index].id,
                                                    postId: widget.postId),
                                              )
                                            ],
                                          ),
                                        ));
                                      });
                            }),
                        Row(
                          children: [
                            Expanded(
                              child: Visibility(
                                child: Container(
                                  width: 50.0,
                                  height: 45.0,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        newAnswer = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2.0),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      border: OutlineInputBorder(),
                                      hintText: 'Add an answer..',
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              child: Text("POST",
                                  style: TextStyle(color: Colors.black)),
                              onPressed: () async {
                                if (newAnswer!.isNotEmpty) {
                                  await databaseServices.addComment(
                                      postId: widget.postId,
                                      commenttext: newAnswer!,
                                      created: formatDate(Timestamp.now()),
                                      authorname: FirebaseAuth
                                          .instance.currentUser!.displayName,
                                      authorimage: FirebaseAuth
                                          .instance.currentUser!.photoURL);
                                }
                                FirebaseFirestore _firestore =
                                    FirebaseFirestore.instance;
                                FirebaseAuth _auth = FirebaseAuth.instance;
                                Map<String, dynamic> cuser = {};
                                await _firestore
                                    .collection("users")
                                    .doc(_auth.currentUser!.uid)
                                    .get()
                                    .then((value) => {cuser = value.data()!});
                                Map<String, dynamic> newData = {
                                  'name': cuser['name'],
                                  'email': cuser['email'],
                                  'image': cuser['image'],
                                  'favourites': cuser['favourites'],
                                  'posts': cuser['posts'],
                                  'answers': cuser['answers'] + 1,
                                };
                                print(newData);
                                await _firestore
                                    .collection("users")
                                    .doc(_auth.currentUser!.uid)
                                    .update(newData);
                              },
                            ),
                          ],
                        ),
                      ],
                    ))
            ]),
          ),
        ));
  }
}

class ReplyRender extends StatefulWidget {
  final String commentId;
  final String postId;
  ReplyRender({required this.commentId, required this.postId});

  @override
  _ReplyRenderState createState() => _ReplyRenderState();
}

class _ReplyRenderState extends State<ReplyRender> {
  Stream? replyStream;
  String? newReply;
  DatabaseService databaseService = new DatabaseService();
  void getReplyStream() async {
    Stream? stream;
    stream = await databaseService.getAllReplies(
        postId: widget.postId, commentId: widget.commentId);
    setState(() {
      replyStream = stream;
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
    getReplyStream();
    super.initState();
  }

  // Map<String, dynamic> getUserInfo(String userId) {
  //   return databaseService.getUser(userId: userId);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        StreamBuilder(
            stream: replyStream,
            builder: (context, AsyncSnapshot snapshot) {
              return snapshot.data == null
                  ? Container()
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        // Map<String, dynamic> userInfo =
                        //     getUserInfo(snapshot.data.docs()['Author']);
                        return Container(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
                            child: ListTile(
                              selectedTileColor: Colors.grey[300],
                              title: Text(snapshot.data.docs[index]
                                  .data()['authorname']
                                  .toString()),
                              subtitle: Text(snapshot.data.docs[index]
                                  .data()['replytext']
                                  .toString()),
                              leading: CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot
                                      .data.docs[index]
                                      .data()['authorimage'])),
                              trailing: Text(formatDate(Timestamp.now()),
                                  style: TextStyle(
                                      fontSize: 8.0, color: Colors.grey)),
                            ),
                          ),
                        );
                      });
            }),
        Row(
          children: [
            Expanded(
              child: Container(
                width: 40.0,
                height: 40.0,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      newReply = value;
                    });
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Add a reply..'),
                ),
              ),
            ),
            SizedBox(width: 20.0),
            ElevatedButton(
              child: Text("SEND", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                if (newReply!.isNotEmpty) {
                  await databaseService.addReply(
                      postId: widget.postId,
                      replytext: newReply,
                      created: Timestamp.now(),
                      commentId: widget.commentId,
                      authorname:
                          FirebaseAuth.instance.currentUser!.displayName,
                      authorimage: FirebaseAuth.instance.currentUser!.photoURL);
                }
              },
            ),
          ],
        ),
      ],
    ));
  }
}
