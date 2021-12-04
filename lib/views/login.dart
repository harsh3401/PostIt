import 'package:flutter/material.dart';
import 'package:post_it/views/Register.dart';
import '../services/Validate.dart';
import '../services/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_it/views/mainpage.dart';
import 'package:post_it/views/profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: Form(
          key: _formKey,
          child: Container(
            height: height,
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: width,
                      height: height * 0.45,
                      child: Image.asset(
                        'assets/postit.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    TextFormField(
                      onChanged: (data) {
                        setState(() {
                          email = data;
                        });
                      },
                      validator: (value) {
                        return AuthValidation.emailValidator(email: value);
                      },
                      decoration: InputDecoration(
                        errorBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        hintText: 'Email',
                        suffixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      onChanged: (data) {
                        setState(() {
                          password = data;
                        });
                      },
                      validator: (value) {
                        return AuthValidation.passwordValidator(
                            password: value);
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        errorBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        hintText: 'Password',
                        suffixIcon: Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RaisedButton(
                            child: Text('Login'),
                            color: Colors.redAccent,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                AuthService authService = new AuthService();
                                User? user;
                                await authService
                                    .signInUser(
                                        email: email, password: password)
                                    .then((response) => {user = response});
                                if (user != null) {
                                  print(
                                      "The user has been successfully logged in");
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('Logged in successfully!',
                                        style: TextStyle(color: Colors.black)),
                                    backgroundColor: Colors.green,
                                    elevation: 10,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(10),
                                  ));
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Profile()));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => registerPage()));
                      },
                      child: Text.rich(
                        TextSpan(text: 'Don\'t have an account?   ', children: [
                          TextSpan(
                            text: 'Signup Here',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
/*
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          onChanged: (data) {
                            setState(() {
                              email = data;
                            });
                          },
                          validator: (value) {
                            return AuthValidation.emailValidator(email: value);
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          )),
                      SizedBox(height: 10),
                      TextFormField(
                          obscureText: true,
                          onChanged: (data) {
                            setState(() {
                              password = data;
                            });
                          },
                          validator: (value) {
                            return AuthValidation.passwordValidator(
                                password: value);
                          },
                          decoration: InputDecoration(
                            hintText: "Password",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          )),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            AuthService authService = new AuthService();
                            User? user;
                            await authService
                                .signInUser(email: email, password: password)
                                .then((response) => {user = response});
                            if (user != null) {
                              print("The user has been successfully logged in");
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Mainpage()));
                            }
                          }
                        },
                        child: Text("Log In"),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.amber),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.all(10.0))),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
  */
}
