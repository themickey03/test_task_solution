import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_task_solution/database/news_model.dart';
import 'package:http/http.dart';
import '../database/database_helper.dart';

class SideMenuWidget extends StatefulWidget {
  final ValueChanged onResult;
  const SideMenuWidget({Key? key, required this.onResult}) : super(key: key);

  @override
  State<SideMenuWidget> createState() => _WithSideMenuWidgetNewState();
}

class _WithSideMenuWidgetNewState extends State<SideMenuWidget> {
  final dbHelper = DatabaseHelper.instance;
  List<NewsModel> _news = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  _changeIsEditing() {
    setState(() {
      isEditing = !isEditing;
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

  void _loadNews() async {
    List<NewsModel> news = await dbHelper.getAllNews();
    setState(() {
      _news = news;
    });
  }

  void _addNews(
      String searchText, String requestResult) async {
    NewsModel newNews = NewsModel(
        searchText: searchText,
        requestResult: requestResult);
    int id = await dbHelper.insert(newNews);
    setState(() {
      newNews.id = id;
      _news.add(newNews);
    });
  }

  void _updateNews(int index, String searchText, String requestResult) async {
    NewsModel updatedNews = NewsModel(
        id: _news[index].id,
        searchText: searchText,
        requestResult: requestResult);
    await dbHelper.update(updatedNews);
    setState(() {
      _news[index] = updatedNews;
    });
  }

  void _deleteNews(int index) async {
    await dbHelper.delete(_news[index].id!);
    setState(() {
      _news.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 75,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: ThemeData.light().primaryColor,
              ),
              child: Row(
                children: [
                  const Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Сохраненные темы",
                              style: TextStyle(color: Colors.white)))),
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _changeIsEditing();
                      },
                      icon: const Icon(Icons.edit, color: Colors.white))
                ],
              ),
            ),
          ),
          isEditing
              ? InkWell(
                  onTap: () {
                    TextEditingController textFieldController =
                        TextEditingController();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Добавление темы'),
                            content: TextField(
                                controller: textFieldController,
                                textInputAction: TextInputAction.go,
                                decoration: const InputDecoration(
                                  hintText: "Новая тема",
                                )),
                            actions: <Widget>[
                              MaterialButton(
                                child: const Text('Добавить'),
                                onPressed: () async {
                                  var requestResult = await fetchDataNews(textFieldController.value.text);
                                  _addNews(textFieldController.value.text, jsonEncode(requestResult));
                                  Navigator.of(context).pop();
                                },
                              ),
                              MaterialButton(
                                child: const Text('Отменить'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.grey,
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Новая запись...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                  ),
                )
              : Container(),
          ListView.builder(
              shrinkWrap: true,
              itemCount: _news.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: (){
                        widget.onResult(_news[index]);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          isEditing
                              ? IconButton(
                              onPressed: () {
                                TextEditingController textFieldController =
                                TextEditingController();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Изменение темы'),
                                        content: TextField(
                                          controller: textFieldController,
                                          textInputAction: TextInputAction.go,
                                          decoration: InputDecoration(
                                              hintText:
                                              _news[index].searchText),
                                        ),
                                        actions: <Widget>[
                                          MaterialButton(
                                            child: const Text('Изменить'),
                                            onPressed: () async {
                                              var requestResult = await fetchDataNews(textFieldController.value.text);
                                              _updateNews(
                                                  index,
                                                  textFieldController
                                                      .value.text,
                                                  jsonEncode(requestResult));
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          MaterialButton(
                                            child: const Text('Отменить'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.edit))
                              : Container(),
                          Expanded(
                              child: isEditing
                                  ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(_news[index].searchText))
                                  : SizedBox(
                                  height: 48,
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(_news[index].searchText),
                                      )))),
                          isEditing
                              ? IconButton(
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Внимание!'),
                                      content: Text(
                                          'Вы действительно хотите удалить ${_news[index].searchText} из сохраненных запросов?'),
                                      actions: <Widget>[
                                        MaterialButton(
                                          child: const Text('Да, я хочу'),
                                          onPressed: () {
                                            _deleteNews(index);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        MaterialButton(
                                          child: const Text('Нет, отменить'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete))
                              : Container(),
                        ],
                      )
                    ),
                    const Divider()
                  ],
                );
              })
        ],
      ),
    );
  }
}
