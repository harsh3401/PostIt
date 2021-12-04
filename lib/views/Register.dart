import 'package:flutter/material.dart';
import 'package:post_it/services/Database.dart';
import 'package:post_it/views/login.dart';
import '../services/Validate.dart';
import '../services/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class registerPage extends StatefulWidget {
  const registerPage({Key? key}) : super(key: key);

  @override
  _registerPageState createState() => _registerPageState();
}

final _formKey = GlobalKey<FormState>();

class _registerPageState extends State<registerPage> {
  String? name;
  String? email;
  String? password;

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Container(
              height: height,
              width: width,
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
                            'Register Account',
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
                          name = data;
                        });
                      },
                      validator: (value) {
                        return AuthValidation.nameValidator(name: value);
                      },
                      decoration: InputDecoration(
                        errorBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        hintText: 'Name',
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RaisedButton(
                              child: Text('Register'),
                              color: Colors.redAccent,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  AuthService authService = new AuthService();
                                  DatabaseService databaseService =
                                      new DatabaseService();
                                  User? user;
                                  await authService
                                      .registerUsingEmailPassword(
                                          name: name,
                                          email: email,
                                          password: password)
                                      .then((response) => {user = response});

                                  if (user != null) {
                                    print("The user has been registered as " +
                                        name!);
                                    Map<String, dynamic> newUser = {
                                      'name': name,
                                      'email': user!.email,
                                      'image':
                                          'https://www.w3schools.com/howto/img_avatar.png',
                                      'favourites': [
                                        "nil",
                                      ],
                                      'posts': 0,
                                      'answers': 0,
                                    };
                                    DatabaseService databaseService =
                                        new DatabaseService();
                                    await databaseService
                                        .createNewUser(user!.uid, newUser)!
                                        .then((value) =>
                                            {print("Registered in firestore")});
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Registration successful!',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      backgroundColor: Colors.green,
                                      elevation: 10,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(10),
                                    ));
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()));
                                  }
                                }
                              }),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Text.rich(
                        TextSpan(text: 'Already Have an account ? ', children: [
                          TextSpan(
                            text: 'Login',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Sign Up",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ))),
      body: Container(
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
                            name = data;
                          });
                        },
                        validator: (value) {
                          return AuthValidation.nameValidator(name: value);
                        },
                        decoration: InputDecoration(
                          hintText: "Name",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        )),
                    SizedBox(height: 10),
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
                          DatabaseService databaseService =
                              new DatabaseService();
                          User? user;
                          await authService
                              .registerUsingEmailPassword(
                                  name: name, email: email, password: password)
                              .then((response) => {user = response});
                          if (user != null) {
                            print("The user has been registered as " + name!);
                            Map<String, dynamic> newUser = {
                              'name': name,
                              'email': user!.email,
                              'image':
                                  'https://www.w3schools.com/howto/img_avatar.png',
                              'favourites': [
                                "nil",
                              ],
                              'posts': 0,
                              'answers': 0,
                            };
                            DatabaseService databaseService =
                                new DatabaseService();
                            await databaseService
                                .createNewUser(user!.uid, newUser)!
                                .then((value) =>
                                    {print("Registered in firestore")});
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          }
                        }
                      },
                      child: Text("Sign Up"),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.amber),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(10.0))),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }*/
}
