import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
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
  final LocalStorage storage = LocalStorage('localstorage_app');
  String? _selectedComponent;
  List _components = [];
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController schemeController = TextEditingController();
  TextEditingController hostController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController baseVersionController = TextEditingController();

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
    setState(() =>
        {_components = resBody, _selectedComponent = resBody[0]["value"]});
    return "Success";
  }

  void getLocalStorageSpecific(TextEditingController controller, String key) {
    String value = storage.getItem(key) ?? "";
    controller.text = value;
  }

  Future<String> getLocalStorage() async {
    await storage.ready;
    getLocalStorageSpecific(userController, "user");
    getLocalStorageSpecific(passwordController, "password");
    getLocalStorageSpecific(schemeController, "scheme");
    getLocalStorageSpecific(hostController, "host");
    getLocalStorageSpecific(portController, "port");
    return "Ok";
  }

  @override
  void initState() {
    super.initState();
    getComponentData();
    getLocalStorage();
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
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DropdownButton(
                hint: const Text("Select Component"),
                items: _components.map((item) {
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
                controller: baseVersionController,
                decoration: const InputDecoration(
                    labelText: "Select Base Version",
                    hintText: "2.1 or 3.10 or leave blank for most recent"),
              ),
              Container(
                padding: const EdgeInsets.only(top: 32.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: null,
                  child: const Text("Find Version"),
                ),
              )
            ]));
  }

  showConfigDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Configuration", style: TextStyle(fontSize: 24)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "Your domain userid",
                    labelText: "User Name"),
                controller: userController,
              ),
              TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.password),
                      hintText: "Your domain password",
                      labelText: "Password"),
                  obscureText: true,
                  controller: passwordController),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.schema),
                    hintText: "http/https",
                    labelText: "Scheme"),
                controller: schemeController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.computer),
                    hintText: "The server host",
                    labelText: "Host"),
                controller: hostController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                    hintText: "Server port",
                    labelText: "Port"),
                controller: portController,
              ),
            ]),
            actions: <Widget>[
              TextButton(
                child: const Text("Remember"),
                onPressed: () {
                  storage.setItem("user", userController.text);
                  storage.setItem("password", passwordController.text);
                  storage.setItem("scheme", schemeController.text);
                  storage.setItem("host", hostController.text);
                  storage.setItem("port", portController.text);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Don't Remember"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
