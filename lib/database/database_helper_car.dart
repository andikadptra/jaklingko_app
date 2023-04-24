import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperCar {
  static final _databaseMarkers = "myDatabaseCar.db";
  static final _databaseVersion = 1;

  static final Car_table = 'Latlng_table';

  static final columnId = '_id';
  static final nameCar = 'Car';

  // membuat instance DatabaseHelper sebagai singleton
  DatabaseHelperCar._privateConstructor();
  static final DatabaseHelperCar instance = DatabaseHelperCar._privateConstructor();

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

 // membuat tabel Latlng_table
Future _onCreate(Database db, int version) async {
  await db.execute('''
        CREATE TABLE $Car_table (
          $columnId INTEGER PRIMARY KEY,
          $nameCar TEXT NOT NULL
        )
        ''');
}
  

  // insert data
  Future<int> insertCar(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(Car_table, row);
  }

  // update data
  Future<int> updateCar(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(Car_table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // delete data
  Future<int> deleteCar(int id) async {
    Database db = await instance.database;
    return await db.delete(Car_table, where: '$columnId = ?', whereArgs: [id]);
  }

  // ambil semua data
  Future<List<Map<String, dynamic>>> queryAllRowsCar() async {
    Database db = await instance.database;
    return await db.query(Car_table);
  }

  // ambil data berdasarkan id
  Future<Map<String, dynamic>> queryByIdCar(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(Car_table,
        where: '$columnId = ?', whereArgs: [id], limit: 1);
    return result.first;
  }
  
  // ambil data berdasarkan Car
  Future<List<Map<String, dynamic>>> queryByStop(String Car) async {
    Database db = await instance.database;
    return await db.query(Car_table, where: '$nameCar = ?', whereArgs: [Car]);
  }

}