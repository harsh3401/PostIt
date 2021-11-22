import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
class AuthService{
    FirebaseAuth _auth = FirebaseAuth.instance;

    Future<User?> registerUsingEmailPassword({
    required String? name,
    required String? email,
    required String? password,
  }) async {
    User? user;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return user;
  }


  Future signInUser({required String? email, required String? password})async{
     User? user;

     try{
       UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email!, password: password!);
       user = userCredential.user;
     }on FirebaseAuthException catch (e) {
       if(e.code=='user-not-found'){
          print("No user found for that email");
       }else if(e.code=="wrong-password"){
         print("Wrong password was provided");
       }
     }

     return user;
  }


  Future signOutUser()async{
    await _auth.signOut();
    print("Successfully signed out!!");
  }






}