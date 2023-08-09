import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'news_model.dart';

class DatabaseHelper {
  static const _databaseName = "newsApp.db";
  static const _databaseVersion = 1;

  static const table = 'news';

  static const columnId = '_id';
  static const columnSearchText = 'searchText';
  static const columnRequestResult = 'requestResult';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
           CREATE TABLE $table (
             $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
             $columnSearchText TEXT NOT NULL,
             $columnRequestResult TEXT
           )
           ''');
  }

  Future<int> insert(NewsModel newsModel) async {
    Database db = await instance.database;
    return await db.insert(table, newsModel.toMap());
  }

  Future<List<NewsModel>> getAllNews() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return NewsModel.fromMap(maps[i]);
    });
  }

  Future<int> update(NewsModel newsModel) async {
    Database db = await instance.database;
    return await db.update(table, newsModel.toMap(),
        where: '$columnId = ?', whereArgs: [newsModel.id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }


}