import 'package:flutter/material.dart';
import '../models/list_entry.dart';

class CreateListPage extends StatefulWidget {

  CreateListPage({String title = "Crea nuova lista"}) : this.title = title;

  final String title;

  @override
  _CreateNewListState createState() => new _CreateNewListState();

}

class _CreateNewListState extends State<CreateListPage> {

  final _formKey = new GlobalKey<FormState>();
  ListEntry _listEntry = new ListEntry();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Salva', style: new TextStyle(color: Colors.white)),
            disabledTextColor: Colors.black,
            disabledColor: Colors.black,
            onPressed: () {
              final form = _formKey.currentState;
              if(form.validate()) {
                Navigator.of(context).pop(_listEntry);
              }
              return null;
            },
          ),
        ]
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          autovalidate: true,
          child: new Column(
            children: [
              new TextFormField(
                decoration: new InputDecoration(labelText: 'Nome'),
                validator: (val) => val.isEmpty? 'Campo obbligatorio.' : null,
                onSaved: (val) => _listEntry.name = val,
              ),
              new TextFormField(
                decoration: new InputDecoration(labelText: 'Condividi con'),
                validator: (val) => val.isEmpty? 'Campo obbligatorio.' : null,
                onSaved: (val) => val.split(",").map((email) => _listEntry.shareWith.add(email)),
              ),
            ],
          ),
        ),
      )
    );
  }
}