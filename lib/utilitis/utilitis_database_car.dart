import 'package:driver_app/database/database_helper_car.dart';

final dbHelper = DatabaseHelper.instance;

// DATABASE CarECTION

_getDataCar() async {
    final dataCar = await dbHelper.queryAllRowsCar();
    return dataCar;
  }

void _insertDataCar() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnMarkers: 'John',
      DatabaseHelper.columnLatlng: 'North',
    };
    final id = await dbHelper.insertCar(row);
    print('Data baru dengan id: $id telah disimpan.');
    _getDataCar();
  }

  void _updateDataCar() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnMarkers: 'Jane',
      DatabaseHelper.columnLatlng: 'South',
    };
    final rowsAffected = await dbHelper.updateCar(row);
    print('$rowsAffected baris telah diperbarui.');
    _getDataCar();
  }

  void _deleteDataCar() async {
    final id = 1;
    final rowsDeleted = await dbHelper.deleteCar(id);
    print('$rowsDeleted baris telah dihapus.');
    _getDataCar();
  }
