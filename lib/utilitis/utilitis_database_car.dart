import 'package:driver_app/database/database_helper_car.dart';

final dbHelper = DatabaseHelperCar.instance;

// DATABASE CarECTION

  getDataCar() async {
    final dataCar = await dbHelper.queryAllRowsCar();
    return dataCar;
  }

void insertDataCar(String namecar) async {
    Map<String, dynamic> row = {
      DatabaseHelperCar.nameCar: namecar,
    };
    final id = await dbHelper.insertCar(row);
    print('Data baru dengan id: $id telah disimpan.');
    getDataCar();
  }

  void updateDataCar(int id, String namecar) async {
    Map<String, dynamic> row = {
      DatabaseHelperCar.columnId: id,
      DatabaseHelperCar.nameCar: namecar,
    };
    final rowsAffected = await dbHelper.updateCar(row);
    print('$rowsAffected baris telah diperbarui.');
    getDataCar();
  }

  void deleteDataCar(int thisId) async {
    final id = thisId;
    final rowsDeleted = await dbHelper.deleteCar(id);
    print('$rowsDeleted baris telah dihapus.');
    getDataCar();
  }
