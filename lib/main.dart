import 'package:flutter/material.dart';
import 'package:test_task_solution/news/news_list_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: const ColorScheme.light()),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var inputText = "";
  var searched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("NewsViewer"),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: TextField(
            onChanged: (text) {
              setState(() {
                inputText = text;
              });
            },
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  NewsListWidget(requestString: inputText)))
                        },
                    icon: const Icon(Icons.search))),
          ),
        ));
  }
}
