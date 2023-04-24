import 'package:driver_app/database/database_helper_car.dart';
import 'package:driver_app/database/database_helper_user.dart';

// membuat objek DatabaseHelperUser
DatabaseHelperUser dbHelper = DatabaseHelperUser.instance;

// membuat data yang akan disimpan



saveDataUser(String namecar, ruteCar) async {
  Map<String, dynamic> row = {
  DatabaseHelperUser.columnId: 1,
  DatabaseHelperUser.nameCar: namecar,
  DatabaseHelperUser.ruteCar: ruteCar
};

  // menyimpan data ke database
  int id = await dbHelper.insertCar(row);
}


editDataUser(int id, String namecar, ruteCar) async {
// mengubah data yang sudah tersimpan di database
  Map<String, dynamic> updatedRow = {
    DatabaseHelperUser.columnId: 1,
    DatabaseHelperUser.nameCar: namecar,
    DatabaseHelperUser.ruteCar: ruteCar
  };
  int rowsAffected = await dbHelper.updateInfoUser(updatedRow);
}

getDataUser() async {
  List<Map<String, dynamic>> allRows = await dbHelper.queryAllRowsCar();
  print(allRows);
}
