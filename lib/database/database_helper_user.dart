import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseMarkers = "myDatabase.db";
  static final _databaseVersion = 1;

  static final user_table = 'user_table';

  static final columnId = 1;
  static final nameCar = 'car';
  static final ruteCar = 'rute';

  // membuat instance DatabaseHelper sebagai singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // database hanya dapat diakses oleh instance ini
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;

    // jika belum ada database, buat database baru
    _database = await _initDatabase();
    return _database!;
  }

  // inisialisasi database pada lokasi yang berbeda dengan data aplikasi
  _initDatabase() async {
    Directory documentsCarectory = await getApplicationDocumentsDirectory();
    String path = join(documentsCarectory.path, _databaseMarkers);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // membuat tabel user_table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $user_table (
            $columnId INTEGER,
            $nameCar TEXT NOT NULL,
            $ruteCar TEXT NOT NULL,
          )
          ''');
  }
  

  // insert data
  Future<int> insertCar(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(user_table, row);
  }

  // update data
  Future<int> updateInfoUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(user_table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // ambil semua data
  Future<List<Map<String, dynamic>>> queryAllRowsCar() async {
    Database db = await instance.database;
    return await db.query(user_table);
  }

}