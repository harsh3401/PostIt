import 'package:flutter/material.dart';
import '../services/Validate.dart';
import '../services/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
class registerPage extends StatefulWidget {
  const registerPage({ Key? key }) : super(key: key);

  @override
  _registerPageState createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {

  String? name;
  String? email;
  String? password;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("Sign Up",
        style : TextStyle(
          color : Colors.blue,
          fontWeight : FontWeight.bold,
          fontSize : 20,
        )
        )
      ),
      body: Container(
        child : Column(
          mainAxisAlignment : MainAxisAlignment.center,
          crossAxisAlignment : CrossAxisAlignment.center,
          children :<Widget> [
              Form(
                key : _formKey,
                child : Column(children: [
                  TextFormField(
                    onChanged : (data){
                      setState((){
                        name = data;
                      });
                    },
                    validator : (value){
                      return AuthValidation.nameValidator(name : value);
                    },
                    decoration : InputDecoration(
                      hintText : "Name",
                      errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                    )
                  ),
                  SizedBox(height : 10),

                  TextFormField(
                    onChanged : (data){
                      setState((){
                        email = data;
                      });
                    },
                    validator : (value){
                      return AuthValidation.emailValidator(email : value);
                    },
                    decoration : InputDecoration(
                      hintText : "Email",
                      errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                    )
                  ),
                  SizedBox(height : 10),

                  TextFormField(
                    obscureText : true,
                    onChanged : (data){
                      setState((){
                        password = data;
                      });
                    },
                    validator : (value){
                      return AuthValidation.passwordValidator(password : value);
                    },
                    decoration : InputDecoration(
                      hintText : "Password",
                      errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                    )
                  ),
                  SizedBox(height:30),
                  ElevatedButton(
                    onPressed : ()async{
                      if(_formKey.currentState!.validate()){
                         AuthService authService = new AuthService();
                         User? user; await authService.registerUsingEmailPassword(name: name, email: email, password: password)
                                            .then((response)=>{
                                              user = response
                                            });
                         if(user!=null){
                           print("The user has been registered as "+name!);
                         }
                      }
                    },
                    child : Text("Sign Up"),
                    style : ButtonStyle(
                      backgroundColor : MaterialStateProperty.all(Colors.amber),
                      padding : MaterialStateProperty.all(EdgeInsets.all(10.0))),
                    ),

                ],)
              )
          ],
        ),
      ),
    );
  }
}