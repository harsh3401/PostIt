import 'package:flutter/material.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({Key? key}) : super(key: key);

  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.arrow_drop_down_circle),
                      title: const Text('Card title 1'),
                      subtitle: Text(
                        'Secondary Text',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.pink,
                          ),
                          onPressed: () {
                            // Perform some action
                          },
                          child: const Text('ACTION 1'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.pink,
                          ),
                          onPressed: () {
                            // Perform some action
                          },
                          child: const Text('ACTION 2'),
                        ),
                      ],
                    ),
                    //Image.asset('assets/reddit.jpg'),
                  ],
                ),
              );
            }),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: SizedBox(
        child: BottomAppBar(
          color: Colors.red,
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.account_circle),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none),
                iconSize: 30.0,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.forum),
                iconSize: 30.0,
              )
            ],
          ),
        ),
        height: 60.0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _showDialog,
        child: Text(
          '+',
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Post what is on your mind"),
          content: Row(
            children: [Text('test'), Text('test')],
          ),
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
