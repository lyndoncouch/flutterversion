import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(home: VersionsApp()));
}

class VersionsApp extends StatefulWidget {
  const VersionsApp({super.key});

  @override
  State<VersionsApp> createState() => _VersionsAppState();
}

class _VersionsAppState extends State<VersionsApp> {
//  String? _user, _password, _scheme, _host, _port;
  String? _selectedComponent;
  List components = [];

  Future<String> getComponentData() async {
    Uri uri = Uri(
        scheme: "http", host: "192.168.1.77", port: 5000, path: "components");

    // await http
    //     .get(uri, headers: {"Accept": "application/json"})
    //     .then((value) => json.decode(value.body))
    //     .then((value) => setState(() => {components = value}));

    var res = await http.get(uri, headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    // _selectedComponent = resBody[0];
    setState(
        () => {components = resBody, _selectedComponent = resBody[0]["value"]});
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    getComponentData();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                    bottom: const TabBar(tabs: [
                      //   Tab(icon: Icon(Icons.directions_car)),
                      //   Tab(icon: Icon(Icons.directions_transit)),

                      Tab(child: Text("Components")),
                      Tab(child: Text("Releases")),
                    ]),
                    title: const Text("Component Versions"),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          showConfigDialog(context);
                        },
                      )
                    ]),
                body: TabBarView(
                  children: [
                    buildComponentsTab(context),
                    const Text("Releases")
                  ],
                ))));
  }

  Widget buildComponentsTab(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DropdownButton(
                hint: const Text("Select Component"),
                items: components.map((item) {
                  return DropdownMenuItem(
                      value: item['artifactory'].toString(),
                      child: Text(item['name']));
                }).toList(),
                onChanged: (newVal) {
                  setState(() => {_selectedComponent = newVal});
                },
                value: _selectedComponent,
              ),
              // child: Text('should be dropdown'),
              // )
              TextFormField(
                decoration: const InputDecoration(
                    labelText: "Select Base Version",
                    hintText: "2.1 or 3.10 or leave blank for most recent"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: null,
                child: const Text("Find Version"),
              ),
            ]));
  }

  showConfigDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Configuration", style: TextStyle(fontSize: 24)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            contentPadding: const EdgeInsets.all(32),
            elevation: 16,
            content: 
				Column(
					
					
					children: [],
				)

        });
  }
}
