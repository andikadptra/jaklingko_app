import 'package:driver_app/database/database_helper_dir.dart';

final dbHelper = DatabaseHelper.instance;

// DATABASE DIRECTION

getDataDir() async {
    final dataDir = await dbHelper.queryAllRowsDir();
    return dataDir;
  }

void insertDataDir(String columnMarkers, columnLatlng, halte) async {
    Map<String, dynamic> row = {
      DatabaseHelper.nameStop: halte,
      DatabaseHelper.columnMarkers: columnMarkers,
      DatabaseHelper.columnLatlng: columnLatlng,
    };
    final id = await dbHelper.insertDir(row);
    print('Data baru dengan id: $id telah disimpan.');
    getDataDir();
  }

  void updateDataDir() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnMarkers: 'Jane',
      DatabaseHelper.columnLatlng: 'South',
    };
    final rowsAffected = await dbHelper.updateDir(row);
    print('$rowsAffected baris telah diperbarui.');
    getDataDir();
  }

  void deleteDataDir(int index) async {
    final id = index;
    final rowsDeleted = await dbHelper.deleteDir(id);
    print('$rowsDeleted baris telah dihapus.');
    getDataDir();
  }
