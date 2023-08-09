import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:collection/collection.dart";
import 'package:sticky_headers/sticky_headers.dart';

import '../database/news_model.dart';

class NewsListWidget extends StatefulWidget {
  final NewsModel requestResult;
  const NewsListWidget({Key? key, required this.requestResult})
      : super(key: key);

  @override
  State<NewsListWidget> createState() => _WithNewsListWidgetNewState();
}

class _WithNewsListWidgetNewState extends State<NewsListWidget> {
  @override
  void initState() {
    super.initState();
  }

  List fetchDataFromResult(){
    return jsonDecode(widget.requestResult.requestResult);
  }

  @override
  Widget build(BuildContext context) {
    var data = fetchDataFromResult();
    var groupByDate = groupBy(
        data, (data) => data["publishedAt"].substring(0, 10));
    if (data.isNotEmpty){
      return ListView.builder(
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
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                        "Новости за ${groupByDate.entries.elementAt(index).key}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Image.network(
                                    urlImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Container();
                                    },
                                  ),
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
                                              ? RichText(
                                            text: TextSpan(
                                                style:
                                                const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors
                                                        .black),
                                                children: [
                                                  const TextSpan(
                                                      text:
                                                      "Источник: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold)),
                                                  TextSpan(
                                                      text: source)
                                                ]),
                                          )
                                              : Container(),
                                          title != ""
                                              ? Text(
                                            title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 16,
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
                                                    fontSize: 12,
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
              ));
        },
      );
    }
    else{
      return Align(
      alignment: Alignment.center,
      child: Padding(padding: EdgeInsets.all(8.0), child: Text("Новостей по теме ${widget.requestResult.searchText} не найдено.", textAlign: TextAlign.center,),),
      );
    }
  }
}
