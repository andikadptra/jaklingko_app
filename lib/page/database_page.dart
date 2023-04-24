import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:driver_app/database/database_helper_dir.dart';

class databasePage extends StatefulWidget {
  databasePage({Key? key}) : super(key: key);

  @override
  State<databasePage> createState() => _databasePageState();
}

class _databasePageState extends State<databasePage> {
  final dbHelper = DatabaseHelperDir.instance;

  List<Map<String, dynamic>> _LatlngList = [];

  void _getLatlngList() async {
    final LatlngList = await dbHelper.queryAllRowsDir();
    setState(() {
      _LatlngList = LatlngList;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLatlngList();
  }

  void _insertData() async {
    Map<String, dynamic> row = {
      DatabaseHelperDir.columnMarkers: 'John',
      DatabaseHelperDir.columnLatlng: 'North',
    };
    final id = await dbHelper.insertDir(row);
    print('Data baru dengan id: $id telah disimpan.');
    _getLatlngList();
  }

  void _updateData() async {
    Map<String, dynamic> row = {
      DatabaseHelperDir.columnId: 1,
      DatabaseHelperDir.columnMarkers: 'Jane',
      DatabaseHelperDir.columnLatlng: 'South',
    };
    final rowsAffected = await dbHelper.updateDir(row);
    print('$rowsAffected baris telah diperbarui.');
    _getLatlngList();
  }

  void _deleteData() async {
    final id = 1;
    final rowsDeleted = await dbHelper.deleteDir(id);
    print('$rowsDeleted baris telah dihapus.');
    _getLatlngList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Databse Page'),
      // ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _LatlngList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_LatlngList[index][DatabaseHelperDir.columnMarkers]),
                subtitle: Text(_LatlngList[index][DatabaseHelperDir.columnLatlng]),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
            ElevatedButton(onPressed: () {
              _insertData();
              setState(() {});
            }, child: Text('add')),
            ElevatedButton(onPressed: () {
              _deleteData();
              setState(() {});
            }, child: Text('delete')),
            ElevatedButton(onPressed: () {
          
            }, child: Text('edit')),
            // FloatingActionButton(
            //   onPressed: _insertData,
            //   tooltip: 'Tambah Data',
            //   child: Icon(Icons.add),
            // ),
            // SizedBox(width: 16),
            // FloatingActionButton(
            //   onPressed: _updateData,
            //   tooltip: 'Perbarui Data',
            //   child: Icon(Icons.edit),
            // ),
            // SizedBox(width: 16),
            // FloatingActionButton(
            //   onPressed: _deleteData,
            //   tooltip: 'Hapus Data',
            //   child: Icon(Icons.delete),
            // ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

