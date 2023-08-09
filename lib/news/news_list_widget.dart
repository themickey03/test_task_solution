import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:collection/collection.dart";
import 'package:sticky_headers/sticky_headers.dart';

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
        "https://newsapi.org/v2/everything?q=${widget.requestString}&sortBy=publishedAt&apiKey=4e24d2cb40d9475ebf7e6f4028364166";
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
            var groupByDate = groupBy(
                snapshot.data!, (data) => data["publishedAt"].substring(0, 10));
            children = ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: groupByDate.entries.length,
                itemBuilder: (context, index) {
                  return StickyHeader(
                      header: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: ThemeData.light().scaffoldBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Новости за ${groupByDate.entries.elementAt(index).key}", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                groupByDate.entries.elementAt(index).value.length,
                                itemBuilder: (context, singleIndex) {
                                  List data =
                                      groupByDate.entries.elementAt(index).value;
                                  var source = "";
                                  var title = "";
                                  var description = "";
                                  var publishTime = "";
                                  var urlImage = "";
                                  var newsUrl = "";

                                  if (data[singleIndex]["source"]["name"] != null &&
                                      data[singleIndex]["source"]["name"] != "") {
                                    source = data[singleIndex]["source"]["name"];
                                  }

                                  if (data[singleIndex]["title"] != null &&
                                      data[singleIndex]["title"] != "") {
                                    title = data[singleIndex]["title"];
                                  }

                                  if (data[singleIndex]["description"] != null &&
                                      data[singleIndex]["description"] != "") {
                                    description = data[singleIndex]["description"];
                                  }

                                  if (data[singleIndex]["url"] != null &&
                                      data[singleIndex]["url"] != "") {
                                    newsUrl = data[singleIndex]["url"];
                                  }

                                  if (data[singleIndex]["publishedAt"] != null &&
                                      data[singleIndex]["publishedAt"] != "") {
                                    try {
                                      publishTime = DateFormat('dd-MM-yyyy HH:mm')
                                          .format(DateTime.parse(
                                          data[singleIndex]["publishedAt"]));
                                    } on Exception catch (_) {
                                      publishTime = "";
                                    }
                                  }

                                  if (data[singleIndex]["urlToImage"] != null &&
                                      data[singleIndex]["urlToImage"] != "") {
                                    urlImage = data[singleIndex]["urlToImage"];
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
                                                    errorBuilder: (_, __, ___) {
                                                      return Container();
                                                    },
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
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 8.0),
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
                                                            FontWeight
                                                                .bold),
                                                      )
                                                          : Container(),
                                                      description != ""
                                                          ? Text(
                                                        description,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                          : Container(),
                                                      publishTime != ""
                                                          ? Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            publishTime,
                                                            textAlign:
                                                            TextAlign.right,
                                                            style:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .grey),
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
                      )
                        );
                },
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
          children = const Text("Ошибка запроса. Попробуйте еще раз.");
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
