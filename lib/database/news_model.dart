class NewsModel{
  int? id;
  var searchText;
  var requestResult;
  var timeOfRequest;

  NewsModel({
    this.id,
    required this.searchText,
    required this.requestResult,
    required this.timeOfRequest
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'searchText': searchText,
      'requestResult': requestResult,
      'timeOfRequest': timeOfRequest
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['_id'],
      searchText: map['searchText'],
      requestResult: map['requestResult'],
      timeOfRequest: map['timeOfRequest']
    );
  }
}