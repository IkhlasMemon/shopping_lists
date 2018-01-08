import 'dart:async';
import 'dart:convert' show JSON;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'pages/create_list.dart';
import 'models/list_entry.dart';


final GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

final FirebaseApp app = new FirebaseApp(
  name: 'flutter-list-app',
  options: const FirebaseOptions(
    googleAppID: '1:890384083726:android:66c39ebc27e56296',
    apiKey: 'AIzaSyBqjbwoBLQ2ODElXgTlfHhD2_4YjGfFAgw',
    databaseURL: 'https://flutter-list-app.firebaseio.com',
  )
);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Shopping lists',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Lista delle spese'),
      routes: <String, WidgetBuilder> {
        '/create-list': (BuildContext context) => new CreateListPage(title: 'Crea nuova lista'),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DatabaseReference _shoppingLists;
  GoogleSignInAccount _currentUser;
  List<ListEntry> _entries = new List();

  @override
  void initState() {
    super.initState();

    FirebaseApp.configure(name: app.name, options: app.options);
    final FirebaseDatabase database = new FirebaseDatabase(app: app);
    database.setPersistenceEnabled(true);
    _shoppingLists = database.reference().child('shoppingLists');

    //configure google sign in
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  void _createNewList() {
    Navigator.pushNamed(context, '/create-list');
  }

  Future _openCreateListDialog() async {
    ListEntry save = await Navigator.of(context).push(
      new MaterialPageRoute<ListEntry>(
        builder: (BuildContext context) {
          return new CreateListPage();
        },
        fullscreenDialog: true
      )
    );
    if (save != null) {
      _addList(save);
    }
  }

  void _addList(ListEntry entry) {
    setState(() {
      _entries.add(entry);
      _shoppingLists.child(_currentUser.id).child(entry.id.toString()).set(entry.toJson());
    });
  }

  Future<Null> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();

/*       _shoppingLists.reference().onChildAdded.listen((Event event) {
        debugPrint(event.snapshot.value.toString());
        ListEntry entry = JSON.decode(event.snapshot.value.toString(), reviver: (dynamic key, value) {
          if(key != null && key.contains("-")) {
            return new ListEntry.fromJson(value);
          }
        });
        _addList(entry);
      }); */

/*       _shoppingLists.reference().child(_currentUser.id).onValue.listen((Event event) {
        debugPrint(event.snapshot.value.toString());
        List<ListEntry> lists = JSON.decode(event.snapshot.value.toString(), reviver: (dynamic key, value) {
          if(key != null && key.contains("-")) {
            debugPrint(value.toString());
            return new ListEntry.fromJson(value);
          }
        });
        setState(() {
          _entries = lists;
        });
      }); */
    } catch (error) {
      debugPrint(error);
    }
  }

  Future<Null> _handleSignOut() async {
    await _googleSignIn.disconnect();
  }

  void _select(choice) {
    switch(choice) {
      case 'login':
        _handleSignIn();
        setState(() {
          _entries = [];
        });
      break;

      case 'logout':
        _handleSignOut();
        setState(() {
          _entries = [];
        });
      break;

      case 'remove_selected':
        List<num> ids = [];
        _entries.forEach((ListEntry entry) {
          if(entry.remove) {
            ids.add(entry.id);
            //remove from firebase
          }
        });
      break;
    }
  }

  _createListView() {
    if(_entries.isEmpty) {
      return new EmptyList();
    }
    return new ListView.builder(
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      reverse: false,
      shrinkWrap: true,
      itemCount: _entries.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          leading: new Column(
            children: <Widget>[
              new Icon(Icons.shop),
              new Text("${_entries[index].items.length}"),
              new Text("elementi", style: new TextStyle(fontSize: 10.0))
            ],
          ),
          title: new Row(
            children: <Widget>[
              new Expanded(child: new Text(_entries[index].name)),
              new Checkbox(
                value: _entries[index].remove,
                onChanged: (bool value) {
                  setState(() {
                    _entries[index].remove = value;
                  });
                },
              )
            ],
          ),
          subtitle: new Text(_entries[index].shareWith.join(',')),
        );
      },
    );
  }

  Widget _buildBody() {
    if(_currentUser == null) {
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Devi prima auteticarti con il tuo account gmail',
            ),
            new RaisedButton(
              child: new Text(
                'Entra',
                style: new TextStyle(color: Colors.white)
              ),
              onPressed: _handleSignIn,
              color: Colors.blue,
            ),
          ],
        ),
      );
    } else {
      return new Container(
        padding: new EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(bottom: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(right: 10.0),
                        child: new Hero(
                          tag: _currentUser.id,
                          child: new CircleAvatar(
                            backgroundImage: new NetworkImage(_currentUser.photoUrl),
                          ),
                        )
                      ),
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Text(
                            _currentUser.displayName,
                            style: new TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          )
                        ]
                      ),
                      new Row(
                        children: <Widget>[
                          new Text(_currentUser.email)
                        ]
                      )
                    ]
                  ),
                ],
              ),
            ),
            new Divider(),
            new Expanded(
              child: _createListView(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFloatingButton() {
    return new Opacity(
      opacity: _currentUser != null ? 1.0 : 0.0,
      child: new FloatingActionButton(
        onPressed: _openCreateListDialog,
        tooltip: 'Crea una nuova lista',
        child: new Icon(Icons.add),
      )
    );
  }

  List<PopupMenuItem> _buildPopupMenuItems() {
    if(_currentUser == null) {
      return [
          new PopupMenuItem(
          value: 'login',
          child: new Text("Login"),
        )
      ];
    }
    return [
      new PopupMenuItem(
        value: 'remove_selected',
        enabled: _entries.any((ListEntry entry) => entry.remove),
        child: new Text("Elimina selezionati"),
      ),
      new PopupMenuItem(
        value: 'logout',
        child: new Text("Esci"),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          new PopupMenuButton( // overflow menu
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return _buildPopupMenuItems();
            },
          ),
        ]
      ),
      body: new ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }
}

class EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text('Non hai liste'),
        ],
      ),
    );
  }
}