import 'package:flutter/material.dart';
import '../services/Validate.dart';
import '../services/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar : AppBar(
          title : Text("Login",
          style : TextStyle(
            color : Colors.blue,
            fontSize : 20,
            fontWeight : FontWeight.bold,
          ),
          
          ),
          centerTitle : true,
        ),
        body : Container(
          child : Container(
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
                         User? user; await authService.signInUser(email: email, password: password)
                                            .then((response)=>{
                                              user = response
                                            });
                         if(user!=null){
                           print("The user has been successfully logged in");
                         }
                      }
                    },
                    child : Text("Log In"),
                    style : ButtonStyle(
                      backgroundColor : MaterialStateProperty.all(Colors.amber),
                      padding : MaterialStateProperty.all(EdgeInsets.all(10.0))),
                    ),

                ],)
              )
          ],
        ),
      ),
      ),
      ); 
  }
}