import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperDir {
  static final _databaseMarkers = "myDatabase.db";
  static final _databaseVersion = 1;

  static final dir_table = 'Latlng_table';

  static final columnId = '_id';
  static final nameStop = 'halte';
  static final columnMarkers = 'markers';
  static final columnLatlng = 'latlng';

  // membuat instance DatabaseHelperDir sebagai singleton
  DatabaseHelperDir._privateConstructor();
  static final DatabaseHelperDir instance = DatabaseHelperDir._privateConstructor();

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseMarkers);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // membuat tabel Latlng_table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $dir_table (
            $columnId INTEGER PRIMARY KEY,
            $nameStop TEXT NOT NULL,
            $columnMarkers TEXT NOT NULL,
            $columnLatlng TEXT NOT NULL
          )
          ''');
  }
  

  // insert data
  Future<int> insertDir(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(dir_table, row);
  }

  // update data
  Future<int> updateDir(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(dir_table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // delete data
  Future<int> deleteDir(int id) async {
    Database db = await instance.database;
    return await db.delete(dir_table, where: '$columnId = ?', whereArgs: [id]);
  }

  // ambil semua data
  Future<List<Map<String, dynamic>>> queryAllRowsDir() async {
    Database db = await instance.database;
    return await db.query(dir_table);
  }

  // ambil data berdasarkan id
  Future<Map<String, dynamic>> queryByIdDir(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(dir_table,
        where: '$columnId = ?', whereArgs: [id], limit: 1);
    return result.first;
  }
  
  // ambil data berdasarkan Halte
  Future<List<Map<String, dynamic>>> queryByStop(String Halte) async {
    Database db = await instance.database;
    return await db.query(dir_table, where: '$nameStop = ?', whereArgs: [Halte]);
  }

  // ambil data berdasarkan Markers
  Future<List<Map<String, dynamic>>> queryByMarkers(String Markers) async {
    Database db = await instance.database;
    return await db.query(dir_table, where: '$columnMarkers = ?', whereArgs: [Markers]);
  }

  // ambil data berdasarkan Latlng
  Future<List<Map<String, dynamic>>> queryByLatlng(String Latlng) async {
    Database db = await instance.database;
    return await db.query(dir_table, where: '$columnLatlng = ?', whereArgs: [Latlng]);
  }
}