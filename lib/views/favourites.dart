import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:post_it/views/mainpage.dart';
import 'package:post_it/views/postDetail.dart';
import 'package:post_it/views/profile.dart';

class FavouritesPosts extends StatefulWidget {
  const FavouritesPosts({Key? key}) : super(key: key);

  @override
  _FavouritesPostsState createState() => _FavouritesPostsState();
}

class _FavouritesPostsState extends State<FavouritesPosts> {
  List<dynamic> favouritelist = [];

  void getfavs() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance;
    Map<String, dynamic> cuser = {};
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {cuser = value.data()!});

    List<dynamic> favlist = cuser['favourites'];

    setState(() {
      favouritelist = favlist;
    });
  }

  @override
  void initState() {
    getfavs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Favourite questions',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
          child: BottomAppBar(
        color: Colors.red,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Profile()));
              },
              icon: Icon(Icons.account_circle),
              iconSize: 30.0,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Mainpage()));
              },
              icon: Icon(Icons.home),
              color: Colors.black,
              iconSize: 30.0,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite_outline),
              color: Colors.grey,
              iconSize: 30.0,
            )
          ],
        ),
      )),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        shrinkWrap: true,
        children: List.generate(
          favouritelist.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: index == 0
                  ? null
                  : GestureDetector(
                      onTap: () {
                        String postId = favouritelist[index].substring(
                            (favouritelist[index].indexOf('(') + 1),
                            favouritelist[index].indexOf(')'));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostDetail(
                                    postId: postId,
                                    postimageurl:
                                        'https://www.w3schools.com/howto/img_avatar.png')));
                      },
                      child: Container(
                        child: Center(
                          child: Text(favouritelist[index].substring(
                              (favouritelist[index].indexOf(')') + 1))),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
