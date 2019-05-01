import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cpd_assignment/utils/beer.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;

  DatabaseHelper._createInstance();

  static Database _database;

  String beerTable = 'beer_table';
  String colId = 'id';
  String colName = 'name';
  String colLocation = 'location';
  String colRating = 'rating';
  String colDrankWith = 'drank_with';
  String colNotes = 'notes';
  String colDate = 'date_drank';
  String colPathImage1 = 'path_image_1';
  String colPathImage2 = 'path_image_2';
  String colPathImage3 = 'path_image_3';

  //Return databaseHelper, which manages database creation and version management
  factory DatabaseHelper() {

    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  //Returns the database
  //If no database exists, initialize one
  Future<Database> get database async {

    if (_database == null){
      _database = await initializeDatabase();
    }

    return _database;
  }

  //Initialize database with appropriate local path and then return it
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'beer.db';

    var beerDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return beerDatabase;
  }

  //Create a database with all columns according to the Beer class
  void _createDb(Database db, int newVersion) async {
    
    await db.execute('CREATE TABLE $beerTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
    '$colName TEXT, $colLocation TEXT, $colRating TEXT, $colDrankWith TEXT, $colNotes TEXT, '
    '$colDate TEXT, $colPathImage1 TEXT, $colPathImage2 TEXT, $colPathImage3 TEXT)');
  }

  //Return the Beer objects from the database
  Future<List<Map<String, dynamic>>> getBeerMapList() async {
    Database db = await this.database;

    var result = await db.query(beerTable);
    return result;
  }

  //Insert a Beer object into the database
  Future<int> insertBeer(Beer beer) async {
    Database db = await this.database;
    Map mapBeer = beer.toMap();
    var result = await db.insert(beerTable, mapBeer);
    return result;
  }

  //Update a beer object from the database
  Future<int> updateBeer(Beer beer) async {
    Database db = await this.database;
    var result = await db.update(beerTable, beer.toMap(), where: '$colId = ?', whereArgs: [beer.id]);
    return result;
  }

  //Delete a Beer object from the database
  Future<int> deleteBeer(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $beerTable WHERE $colId = $id');
    return result;
  }

  //Return total number of objects in the database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $beerTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<Map> getAll() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT * FROM $beerTable');
    //int result = Sqflite.firstIntValue(x);
    return x.asMap();
  }

  //Fetches the Map List (List<Map>) from the database and converts it to Beer List (List<Beer>)
  Future<List<Beer>> getBeerList() async {

    var beerMapList = await getBeerMapList();
    int count = beerMapList.length;

    List<Beer> beerList = List<Beer>();
    for (int i = 0; i < count; ++i) {
      beerList.add(Beer.fromMapObject(beerMapList[i]));
    }

    return beerList;
  }


}