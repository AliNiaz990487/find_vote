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
  Widget voterInfo = const SizedBox();
  final TextEditingController _controller = TextEditingController();

  Future<Map<String, List<dynamic>>> _loadJsonData() async {
    final String response = await rootBundle.loadString('assets/voters_list.json');
    final data = json.decode(response);
    return Map<String, List<dynamic>>.from(data);
  }

  Widget search() {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Enter CNIC (without dashes)',
        hintText: '1620123456789',
        border: const OutlineInputBorder(),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _controller.clear();
                    voterInfo = const SizedBox();
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
      maxLength: 13,
    );
  }

  Widget findButton(voterData){
    Widget primaryText(str){
      return Text(" " + str + " ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),);
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextButton(
        
        onPressed: () {
          if (_controller.text.length < 13) {return;}
          final voter = voterData[_controller.text];
          if (voter != null) {
            setState(() {
              voterInfo = SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    border: TableBorder.all(width: 1.5, color:Colors.black),
                    
                    children: [
                      TableRow(children: [primaryText("Name "), primaryText(voter[4].toString())]),
                      TableRow(children: [primaryText("CNIC "), primaryText(_controller.text)]),
                      TableRow(children: [primaryText("Vote Number "), primaryText(voter[3].toString())]),
                      TableRow(children: [primaryText("Book Number "), primaryText(voter[1].toString())]),
                      TableRow(children: [primaryText("School "), primaryText(voter[2].toString())]),
                      TableRow(children: [primaryText("Zone "), primaryText(voter[0].toString())]),
                    ],
                  ),
                ),
              );
            });
          } else {
            setState(() {
              voterInfo = const SizedBox(); // Reset voterInfo if voter is not found
            });
          }
        },
        style: const ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(Colors.white),
          backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 8, 69, 29))),
        child: const Text("Find"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Vote'),
          backgroundColor: const Color.fromARGB(255, 31, 151, 35),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 35),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'), // Path to your background image
              opacity: 0.5
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
                  Map<String, List<dynamic>>? voterData = snapshot.data;
                  if (voterData != null) {
                    return ListView(
                      children: [
                        search(),
                        findButton(voterData),
                        voterInfo,
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
        bottomSheet: const Text("© Gul Alam Khan ❤️", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
