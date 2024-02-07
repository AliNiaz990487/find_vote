import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(),
      )
  );

  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find Vote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<dynamic, dynamic>? voterData;
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<List<String>> _suggestionsNotifier = ValueNotifier<List<String>>([]);
  bool showSuggestions = false;

  @override
  void dispose() {
    _suggestionsNotifier.dispose();
    super.dispose();
  }

  Future<Map> _loadJsonData() async {
    final String response = await rootBundle.loadString('assets/voters_list.json');
    final data = json.decode(response);
    return Map<String, List<dynamic>>.from(data);
  }

  void updateSuggestions(String text, {bool lastMatch = false}) {
    if (voterData == null) return;
    if (text.isEmpty || text.length < 8) {
      _suggestionsNotifier.value = [];
      return;
    }

    final RegExp regex = RegExp(text);
    final List<String> matches = [];

    // Loop through voterData to find matching CNICs
    for (var cnic in voterData!.keys) {
      if (regex.hasMatch(cnic)) {
        matches.add(cnic);
      }
    }

    _suggestionsNotifier.value = matches;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Vote'),
          backgroundColor: const Color.fromARGB(255, 31, 151, 35),
          titleTextStyle: const TextStyle(
            color: Colors.white, 
            fontSize: 35,
            fontStyle: FontStyle.italic
          ),
          toolbarHeight: 70,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'), // Path to your background image
              opacity: 0.5,
              // fit: BoxFit.fitHeight, // Optional: Defines how the background image should be resized to cover the entire container
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: _loadJsonData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  voterData = snapshot.data;
                  if (voterData != null) {
                    return ListView(
                      children: [
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Enter CNIC (without dashes)',
                            hintText: '1620123456789',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  _suggestionsNotifier.value = [];
                                },
                                icon: const Icon(Icons.clear),
                              )
                          ),
                          maxLength: 13,
                          onChanged: (text) {
                            updateSuggestions(text);
                          },
                        ),
                        ValueListenableBuilder<List<String>>(
                          valueListenable: _suggestionsNotifier,
                          builder: (context, suggestions, _) {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: suggestions
                                    .map(
                                      (suggestion) => ListTile(
                                        title: Text(suggestion),
                                        onTap: () {
                                          _controller.text = suggestion;
                                          updateSuggestions(suggestion);
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            final voter = voterData![_controller.text];
                            if (voter != null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Voter Details"),
                                    content: Table(
                                        border: TableBorder.all(width: 1.5, color: Colors.black),
                                        children: [
                                          TableRow(children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("Name "),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(voter[4].toString()),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("CNIC "),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(_controller.text),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("Vote Number "),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(voter[3].toString()),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("Book Number "),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(voter[1].toString()),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("School "),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(voter[2].toString()),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text("Zone "),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(voter[0].toString()),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Voter Not Found"),
                                    content: const Text("No voter found with the provided CNIC."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 8, 69, 29)),
                          ),
                          child: const Text("Find"),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                }
              },
            ),
          ),
        ),
        bottomSheet: const Text("© Gul Alam Khan ❤️ @AN", style: TextStyle(fontSize: 12)),
      ),
    );
  }
}
