import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class DatabaseService{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future? getPostData()async{
     return await _firestore.collection("posts").snapshots();
  }

  Future? createNewPost(Map<String,dynamic>newPost,String postId)async{

    await _firestore.collection("posts").doc(postId).set(newPost)
    .catchError((err)=>{
      print(err),
    });
  }

  Future? getPost(String quizId)async{
    Stream stream;
    try{
      return await _firestore.collection("posts").doc(quizId);
    }catch(err){
      print(err);
      return null;
    }
    
  }

  Future? deletePost(String quizId,User? currentUser)async{
    DocumentReference reference;
    reference = await getPost(quizId);
    Map<String, dynamic>? fetchedData;
    reference.get()
    .then((value){
        fetchedData = value.data();
    });
    if(fetchedData!=null && currentUser!.uid==fetchedData!['author']){
      await reference.delete()
      .catchError((e)=>{
        print(e),
      });
    }
  }



}