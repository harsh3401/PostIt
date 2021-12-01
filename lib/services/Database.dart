import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      required String authorId,
      required String commenttext}) async {
    Map<String, dynamic> newComment = {
      "author": authorId,
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
      required String replytext,
      required String commentId,
      required String authorId}) async {
    Map<String, dynamic> newReply = {
      "author": authorId,
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

  Future<Map<String, dynamic>> getUser({required String userId}) async {
    DocumentReference documentReference;
    documentReference = _firestore.collection("users").doc(userId);
    Map<String, dynamic> data = {};
    documentReference
        .get()
        .then((value) => {
              data = value.data()!,
              print(data),
            })
        .catchError((err) => {print(err)});
    return data;
  }
}
