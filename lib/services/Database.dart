import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future? createNewUser(userId, newUser) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(newUser)
        .then((res) => {
              print("Saved the user succesfully into firestore"),
            })
        .catchError((err) => {
              print('here in errror'),
              print(err),
            });
  }

  Future? getPostData() async {
    return await _firestore.collection("posts").snapshots();
  }

  Future? createNewPost(Map<String, dynamic> newPost, String postId) async {
    await _firestore
        .collection("posts")
        .doc(postId)
        .set(newPost)
        .catchError((err) => {
              print(err),
            });
  }

  Future? getPost(postId) async {
    Stream stream;
    try {
      return await _firestore.collection("posts").doc(postId);
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future? deletePost(String quizId, User? currentUser) async {
    DocumentReference reference;
    reference = await getPost(quizId);
    Map<String, dynamic>? fetchedData;
    reference.get().then((value) {
      fetchedData = value.data();
    });
    if (fetchedData != null && currentUser!.uid == fetchedData!['author']) {
      await reference.delete().catchError((e) => {
            print(e),
          });
    }
  }

  Future<void> addComment(
      {required String postId,
      required String? authorname,
      required String? authorimage,
      required String created,
      required String commenttext}) async {
    Map<String, dynamic> newComment = {
      "authorname": authorname,
      "authorimage": authorimage,
      "commenttext": commenttext,
    };

    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .add(newComment)
          .catchError((err) => {print(err)});
    } catch (error) {
      print(error);
    }
  }

  Future<Stream?> getAllComments({required String postId}) async {
    Stream stream;
    try {
      stream = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .snapshots();
      return stream;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Stream?> getAllReplies(
      {required String postId, required String commentId}) async {
    Stream stream;

    try {
      stream = await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .snapshots();
      return stream;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> addReply(
      {required String postId,
      required String? replytext,
      required Timestamp created,
      required String commentId,
      required String? authorname,
      required String? authorimage}) async {
    Map<String, dynamic> newReply = {
      "authorname": authorname,
      "authorimage": authorimage,
      "replytext": replytext,
    };
    await _firestore
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .collection("replies")
        .add(newReply)
        .catchError((error) => {print(error)});
  }

  DocumentReference getUser({required String userId}) {
    DocumentReference documentReference;
    documentReference = _firestore.collection("users").doc(userId);
    return documentReference;
  }

  Future? updateUserInfo(newData, userId) async {
    DocumentReference reference;
    reference = _firestore.collection("users").doc(userId);
    Map<String, dynamic>? fetchedData;
    reference.get().then((value) {
      fetchedData = value.data();
    });
    print('fetchedData is $fetchedData');
    if (fetchedData != null) {
      await reference.update(newData).catchError((e) => {
            print(e),
          });
    }
  }
}
