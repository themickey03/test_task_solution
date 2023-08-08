import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class NewsListWidget extends StatefulWidget {
  final String requestString;
  const NewsListWidget({Key? key, required this.requestString})
      : super(key: key);

  @override
  State<NewsListWidget> createState() => _WithNewsListWidgetNewState();
}

class _WithNewsListWidgetNewState extends State<NewsListWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<List> fetchDataNews() async {
    final url =
        "https://newsapi.org/v2/everything?q=${widget.requestString}&apiKey=cac7862032ad4ea69b21607a0038d32d";
    final response = await get(Uri.parse(url));
    var newsList = [];
    final jsonData = jsonDecode(response.body) as Map;
    setState(() {
      newsList = jsonData["articles"];
    });
    return newsList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchDataNews(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        Widget children;
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty){
            children = Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Text("Source: ${snapshot.data![index]["source"]["name"]}"),
                        Text("Title: ${snapshot.data![index]["title"]}"),
                        Text(
                            "Description: ${snapshot.data![index]["description"]}"),
                        Text(
                            "Publish Time: ${snapshot.data![index]["publishedAt"]}"),
                        const Divider()
                      ],
                    );
                  }),
            );
          }
          else{
            children = Text('Новостей на тему "${widget.requestString}" не найдено.');
          }
        }
        else if (snapshot.hasError){
          children = const Text("Error");
        }
        else{
          children = const CircularProgressIndicator();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.requestString),
          ),
          body: Align(
            alignment: Alignment.center,
            child: children,
          ),
        );
      },
    );
  }
}
