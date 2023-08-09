import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
        "https://newsapi.org/v2/everything?q=${widget.requestString}&apiKey=bc300c7edb654402a633f5c6a61aa191";
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
          if (snapshot.data!.isNotEmpty) {
            children = Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var source = "";
                    var title = "";
                    var description = "";
                    var publishTime = "";
                    var urlImage = "";
                    var newsUrl = "";

                    if (snapshot.data![index]["source"]["name"] != null &&
                        snapshot.data![index]["source"]["name"] != "") {
                      source = snapshot.data![index]["source"]["name"];
                    }

                    if (snapshot.data![index]["title"] != null &&
                        snapshot.data![index]["title"] != "") {
                      title = snapshot.data![index]["title"];
                    }

                    if (snapshot.data![index]["description"] != null &&
                        snapshot.data![index]["description"] != "") {
                      description = snapshot.data![index]["description"];
                    }

                    if (snapshot.data![index]["url"] != null &&
                        snapshot.data![index]["url"] != "") {
                      newsUrl = snapshot.data![index]["url"];
                    }

                    if (snapshot.data![index]["publishedAt"] != null &&
                        snapshot.data![index]["publishedAt"] != "") {
                      try {
                        publishTime = DateFormat('dd-MM-yyyy HH:mm').format(
                            DateTime.parse(
                                snapshot.data![index]["publishedAt"]));
                      } on Exception catch (_) {
                        publishTime = "";
                      }
                    }

                    if (snapshot.data![index]["urlToImage"] != null &&
                        snapshot.data![index]["urlToImage"] != "") {
                      urlImage = snapshot.data![index]["urlToImage"];
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            urlImage != ""
                                ? Flexible(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Image.network(
                                            urlImage,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            Flexible(
                              flex: 2,
                              child: InkWell(
                                  onTap: () {
                                    //TODO alert if link not found
                                    launchUrl(Uri.parse(newsUrl),
                                        mode: LaunchMode.externalApplication);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        source != ""
                                            ? Text("Источник: $source")
                                            : Container(),
                                        title != ""
                                            ? Text(
                                                title,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Container(),
                                        description != ""
                                            ? Text(
                                                description,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Container(),
                                        publishTime != ""
                                            ? Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  publishTime,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                ))
                                            : Container(),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    );
                  }),
            );
          } else {
            children = Align(
                alignment: Alignment.center,
                child: Text(
                  'Новостей на тему "${widget.requestString}" не найдено.',
                  textAlign: TextAlign.center,
                ));
          }
        } else if (snapshot.hasError) {
          children = const Text("Error");
        } else {
          children = const CircularProgressIndicator();
        }
        return Align(
          alignment: Alignment.center,
          child: children,
        );
      },
    );
  }
}
