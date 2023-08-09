class NewsModel{
  int? id;
  var searchText;
  var requestResult;

  NewsModel({
    this.id,
    required this.searchText,
    required this.requestResult,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'searchText': searchText,
      'requestResult': requestResult,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['_id'],
      searchText: map['searchText'],
      requestResult: map['requestResult'],
    );
  }
}