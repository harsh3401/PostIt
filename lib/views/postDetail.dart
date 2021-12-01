import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/Database.dart';

class PostDetail extends StatefulWidget {
  final String postId;

  PostDetail({required String this.postId});
  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  Map<String, dynamic>? Postcontent = {};
  Stream? ansStream;
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

  @override
  void initState() {
    getPostDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Question view"),
        ),
        body: ListView(children: <Widget>[
          Container(
            padding: const EdgeInsets.all(32.0),
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
                          "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // timestamp
                      Text(
                        "",
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
                new Container(
                    padding: const EdgeInsets.all(32.0),
                    child: new Text(
                      "",
                      softWrap: true,
                    ))
              ],
            ),
          )
        ]));
  }
}
