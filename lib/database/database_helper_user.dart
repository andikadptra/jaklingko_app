import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CarDatabase {
  static final CarDatabase instance = CarDatabase._init();

  static Database? _database;

  CarDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('car.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE cars (
  id INTEGER PRIMARY KEY,
  name TEXT,
  route TEXT
)
''');
  }

  Future<Car> create(Car car) async {
    final db = await instance.database;
    final id = await db.insert('cars', car.toJson());
    return car.copy(id: id);
  }

  Future<Car?> read() async {
    final db = await instance.database;
    final maps = await db.query('cars', limit: 1);

    if (maps.isNotEmpty) {
      return Car.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateRoute(String route) async {
    final db = await instance.database;
    return db.update(
      'cars',
      {'route': route},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Car>> readAll() async {
    final db = await instance.database;
    final maps = await db.query('cars');

    return List.generate(maps.length, (i) {
      return Car.fromJson(maps[i]);
    });
  }
}

class Car {
  final int? id;
  final String name;
  final String route;

  Car({
    this.id,
    required this.name,
    required this.route,
  });

  Car copy({
    int? id,
    String? name,
    String? route,
  }) =>
      Car(
        id: id ?? this.id,
        name: name ?? this.name,
        route: route ?? this.route,
      );

  static Car fromJson(Map<String, Object?> json) => Car(
        id: json['id'] as int?,
        name: json['name'] as String,
        route: json['route'] as String,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'route': route,
      };
}
