import 'package:flutter/material.dart';
import 'package:test_task_solution/news/news_list_widget.dart';
import 'package:test_task_solution/sideMenu/side_menu_widget.dart';

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
  var lastSearchText = "";
  var searched = false;
  var isSearched = false;

  _changeSetOfSearch() {
    setState(() {
      isSearched = !isSearched;
    });
  }
  
  _changeInputText(String text){
    setState(() {
      inputText = text;
    });
  }

  _changeLastSearchText(String text){
    setState(() {
      lastSearchText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: SideMenuWidget(onResult: (result) {
          _changeLastSearchText(result);
          _changeInputText("");
          setState(() {
            isSearched = true;
          });
        },),
        appBar: AppBar(
          backgroundColor: ThemeData.light().primaryColor,
          elevation: 0,
          title: isSearched ? Text(lastSearchText) : const Text("NewsViewer"),
          actions: [
            isSearched ? IconButton(
              icon: const Icon(Icons.search),
              onPressed: (){
                _changeSetOfSearch();
              },
            ) : Container()
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            child: Column(
              children: [
                !isSearched
                    ? Padding(
                      padding: const EdgeInsets.only(left:8.0, right: 8.0),
                      child: TextField(
                          onChanged: (text) {
                            _changeInputText(text);
                          },
                          decoration: InputDecoration(
                            hintText: "Введите тему для поиска",
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    if (inputText.isNotEmpty) {
                                      _changeSetOfSearch();
                                      _changeLastSearchText(inputText);
                                      _changeInputText("");
                                    }
                                    else{
                                      _changeSetOfSearch();
                                    }
                                  },
                                  icon: inputText.isNotEmpty ? const Icon(Icons.search) : const Icon(Icons.close))),
                        ),
                    )
                    : Container(),
                isSearched
                    ? Expanded(child: NewsListWidget(requestString: lastSearchText))
                    : Container()
              ],
            ),
          ),
        ));
  }
}
