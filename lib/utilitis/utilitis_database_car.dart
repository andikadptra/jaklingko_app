import 'package:driver_app/database/database_helper_car.dart';

final dbHelper = DatabaseHelper.instance;

// DATABASE CarECTION

_getDataCar() async {
    final dataCar = await dbHelper.queryAllRowsCar();
    return dataCar;
  }

void _insertDataCar(String namecar) async {
    Map<String, dynamic> row = {
      DatabaseHelper.nameCar: namecar,
    };
    final id = await dbHelper.insertCar(row);
    print('Data baru dengan id: $id telah disimpan.');
    _getDataCar();
  }

  void _updateDataCar(int id, String namecar) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.nameCar: namecar,
    };
    final rowsAffected = await dbHelper.updateCar(row);
    print('$rowsAffected baris telah diperbarui.');
    _getDataCar();
  }

  void _deleteDataCar(int thisId) async {
    final id = thisId;
    final rowsDeleted = await dbHelper.deleteCar(id);
    print('$rowsDeleted baris telah dihapus.');
    _getDataCar();
  }
