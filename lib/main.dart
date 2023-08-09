import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:test_task_solution/news/news_list_widget.dart';
import 'package:test_task_solution/sideMenu/side_menu_widget.dart';

import 'database/database_helper.dart';
import 'database/news_model.dart';

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
  var isSearched = true;
  var isNewsEmpty = true;
  var isLoaded = false;
  var currentNewsId = -1;

  final dbHelper = DatabaseHelper.instance;
  List<NewsModel> _news = [];


  @override
  void initState() {
    super.initState();
    _actualizeNews();
    _loadNews();
  }
  _changeInputText(String text) {
    setState(() {
      inputText = text;
    });
  }

  _changeIdOfNews(int id){
    setState(() {
      currentNewsId = id;
    });
  }

  _loadNews() async {
    List<NewsModel> news = await dbHelper.getAllNews();
    setState(() {
      _news = news;
      if (_news.isNotEmpty){
        _changeIdOfNews(_news.last.id!);
      }
      else {
        isSearched = false;
      }
      isLoaded = true;
    });
  }


  _changeSetOfSearch() {
    setState(() {
      isSearched = !isSearched;
    });
  }

  Future<List> fetchDataNews(String request) async {
    final url =
        "https://newsapi.org/v2/everything?q=$request&sortBy=publishedAt&apiKey=09bc85a680f14a6c8880265c4454c3dc";
    final response = await get(Uri.parse(url));
    var newsList = [];
    final jsonData = jsonDecode(response.body) as Map;
    setState(() {
      newsList = jsonData["articles"];
    });
    return newsList;
  }

  Future<int> _addNews(String searchText, String requestResult) async {
    NewsModel newNews =
        NewsModel(searchText: searchText, requestResult: requestResult);
    int id = await dbHelper.insert(newNews);
    setState(() {
      newNews.id = id;
      _news.add(newNews);
    });
    return id;
  }

  _actualizeNews() async {
    for (var element in _news) {
      dbHelper.update(NewsModel(
          id: element.id,
          searchText: element.searchText,
          requestResult: await fetchDataNews(element.searchText)));
    }
  }
  
  int getNewsIdByCurrentId(int id){
    var result = -1;
    for (int i = 0; i < _news.length; i++){
      if (_news[i].id == id){
        result = i;
      }
    }
    return result;
  }
  int getCurrentIdByNewsId(int id){
    var result = -1;
    for (int i = 0; i < _news.length; i++){
      if (_news[i].id == id){
        result = _news[i].id!;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded ? Scaffold(
        drawer: SideMenuWidget(
          onResult: (result) async {
            await _loadNews();
            _changeIdOfNews(getCurrentIdByNewsId(result.id));
            setState(() {
              isSearched = true;
            });
          },
        ),
        appBar: AppBar(
          backgroundColor: ThemeData.light().primaryColor,
          elevation: 0,
          title: isSearched
              ? Text(_news[getNewsIdByCurrentId(currentNewsId)].searchText)
              : const Text("NewsViewer"),
          actions: [
            isSearched
                ? IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _changeSetOfSearch();
              },
            )
                : Container()
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            child: Column(
              children: [
                !isSearched
                    ? Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0),
                  child: TextField(
                    onChanged: (text) {
                      _changeInputText(text);
                    },
                    decoration: InputDecoration(
                        hintText: "Введите тему для поиска",
                        suffixIcon: IconButton(
                            onPressed: () async {
                              if (inputText != "") {
                                var id = await _addNews(inputText, jsonEncode(await fetchDataNews(inputText)));
                                _changeInputText("");
                                _changeIdOfNews(id);
                                _changeSetOfSearch();
                              } else {
                                _changeSetOfSearch();
                              }
                            },
                            icon: inputText != ""
                                ? const Icon(Icons.search)
                                : const Icon(Icons.close))),
                  ),
                )
                    : Container(),
                isSearched && currentNewsId != -1
                    ? Expanded(
                    child: NewsListWidget(
                        requestResult: _news[getNewsIdByCurrentId(currentNewsId)]))
                    : Container()
              ],
            ),
          ),
        )) : Container();
  }
}
