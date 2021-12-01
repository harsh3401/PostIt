import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

class PostDetail extends StatefulWidget {
  final String postId;

  PostDetail({required String this.postId});
  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  Map<String, dynamic>? Postcontent = {
    "Question": "",
    "Author": "",
    "Description": "",
    "imgURL": "",
    "created": Timestamp.now(),
  };
  Stream? ansStream;
  String? newAnswer;

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

  void getAnsStream() async {
    Stream? stream;
    stream = await databaseServices.getAllComments(postId: widget.postId);
    setState(() {
      ansStream = stream;
    });
  }

  void getUserInfo(String userId) {
    print(databaseServices.getUser(userId: userId));
    databaseServices.getUser(userId: userId).get().then((value) => {
          print(value.data()),
        });
  }

  String? getUsername(String userId) {
    String? name;
    databaseServices.getUser(userId: userId).get().then((value) => {
          name = value.data()!['name'],
        });

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
    getUserInfo('E8m0K8YvTVN2T2n7sEWPHnQmb9A2');
    getPostDetails();
    getAnsStream();
    super.initState();
  }

  // DateTime formatDate(Timestamp) {
  //   DateTime myDateTime = (Timestamp).toDate();
  //   DateFormat.yMMMd().add_jm().format(myDateTime);
  //   return myDateTime;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Question view"),
        ),
        body: Column(children: <Widget>[
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // timestamp

                      Text(
                        '2021-01-22', //formatDate(Postcontent!['created']).toString(),
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon to check added to favorite or not
                new Icon(
                  Icons.star,
                  color: Colors.red[500],
                ),
                new Text(''),
                // Description
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.all(2.0),
              child: new Text(
                Postcontent!['Description'].toString(),
                softWrap: true,
              )),
          Container(
              child: Column(
            children: [
              StreamBuilder(
                  stream: ansStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    return snapshot.data == null
                        ? Container()
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 30,
                                height: 30,
                                child: ListTile(
                                  title: Text('Test User'), //getUsername(id)
                                  subtitle: Text(snapshot.data.docs[index]
                                      .data()['commenttext']),
                                  leading: Container(
                                    width: 30,
                                    height: 30,
                                  ), //User post image
                                ),
                              );
                            });
                  }),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          newAnswer = value;
                        });
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Add an answer..'),
                    ),
                  ),
                  ElevatedButton(
                    child: Text("POST"),
                    onPressed: () async {
                      if (newAnswer!.isNotEmpty) {
                        await databaseServices.addComment(
                            postId: widget.postId,
                            commenttext: newAnswer!,
                            created: Timestamp.now(),
                            authorId: FirebaseAuth.instance.currentUser!.uid);
                      }
                    },
                  ),
                ],
              ),
            ],
          ))
        ]));
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

  @override
  void initState() {
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
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        // Map<String, dynamic> userInfo =
                        //     getUserInfo(snapshot.data.docs()['Author']);
                        return Container(
                          height: 20,
                          width: 20,
                          child: ListTile(
                            title: Text("userInfo['username']"),
                            subtitle: Text(snapshot.data.docs()['replytext']),
                            leading: Container(
                              height: 20,
                              width: 20,
                            ),
                          ),
                        );
                      });
            }),
        Row(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  newReply = value;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Add a reply..'),
            ),
            ElevatedButton(
              child: Text("SEND"),
              onPressed: () async {
                if (newReply!.isNotEmpty) {
                  await databaseService.addReply(
                      postId: widget.postId,
                      replytext: newReply,
                      created: Timestamp.now(),
                      commentId: widget.commentId,
                      authorId: FirebaseAuth.instance.currentUser!.uid);
                }
              },
            ),
          ],
        ),
      ],
    ));
  }
}
