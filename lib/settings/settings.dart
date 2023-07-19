import 'package:flutter/material.dart';
import 'package:scrolling_dulu/data/service.dart';

class SettingsPage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _hostController = TextEditingController();
  String _currentBaseUrl = ApiServices.baseUrl;

  @override
  void initState() {
    super.initState();
    _hostController.text = _currentBaseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color.fromRGBO(135, 182, 255, 1),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color.fromRGBO(2, 15, 35, 1),
          title: const Text('Home',
              style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This Settings')));
              },
              color: Color.fromRGBO(135, 182, 255, 1),
            ),
          ],
        ),
        body: ListTile(
            title: const Text('host',
                style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
            subtitle: Text('change host',
                style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
            leading: const Icon(Icons.storage,
                color: Color.fromRGBO(135, 182, 255, 1)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  contentPadding: const EdgeInsets.all(20.0),
                  title: const Text('Host'),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _hostController,
                          style: TextStyle(
                              color: Color.fromRGBO(135, 182, 255, 1)),
                          decoration: InputDecoration(
                            labelText: 'Host',
                            labelStyle: TextStyle(
                                color: Color.fromRGBO(135, 182, 255, 1)),
                            hintStyle: TextStyle(
                                color: Color.fromRGBO(135, 182, 255, 1)),
                            hintText: 'Change Host',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Konfirmasi ganti url
                            String newBaseUrl = _hostController.text;
                            ApiServices.setBaseUrl(newBaseUrl);
                            Navigator.of(context).pop();
                            setState(() {
                              _currentBaseUrl = newBaseUrl;
                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }));
  }
}
