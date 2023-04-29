import 'package:driver_app/components/constants.dart';
import 'package:driver_app/database/database_helper_car.dart';
import 'package:driver_app/database/database_helper_dir.dart';
import 'package:driver_app/database/database_helper_user.dart';
import 'package:driver_app/page/first_page.dart';
import 'package:driver_app/utilitis/utilitis_database_car.dart';
import 'package:driver_app/utilitis/utilitis_database_dir.dart';
import 'package:driver_app/page/wifi_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart';

class carSelect extends StatefulWidget {
  late String carSelectonOutside;
  String rute;
  carSelect({Key? key, required this.carSelectonOutside, required this.rute})
      : super(key: key);

  @override
  State<carSelect> createState() => _carSelectState();
}

class _carSelectState extends State<carSelect> {
  late String catchCarSelect = widget.carSelectonOutside;

  final carDb = CarDatabase.instance;

  TextEditingController _controller = TextEditingController();

  List<String> menuItems = [
    'TAMBAH MOBIL',
    'EDIT NAMA MOBIL',
    'HAPUS MOBIL',
    'PILIH MOBIL'
  ];

  List<Map<String, dynamic>> _fetchData = [];

  void _getData() async {
    _fetchData = await getDataCar();
    setState(() {});
  }

  Future<void> _updateData(String _car, _route) async {
    final updatedCar = Car(
      name: _car,
      route: _route,
    );

    await CarDatabase.instance.updateRoute(updatedCar.route);
    setState(() {
      _route = updatedCar.route;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data berhasil diperbarui')),
    );
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late String appBartxt = widget.carSelectonOutside;
  
  late String selectedRoute;

  Widget build(BuildContext context) {
    
    selectedRoute = widget.rute;

    return Scaffold(
      floatingActionButton: appBartxt == 'TAMBAH MOBIL'
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PopupAdd();
                    });
              },
              label: Text('TAMBAH'),
            )
          : null,
      appBar: AppBar(
        title: Text(appBartxt),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return menuItems.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Container(
                      color: item == appBartxt ? Colors.blue : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item,
                          style: TextStyle(
                              color: item == appBartxt
                                  ? Colors.white
                                  : Colors.blue),
                        ),
                      )),
                );
              }).toList();
            },
            onSelected: (String selectedItem) {
              if (selectedItem == 'TAMBAH MOBIL') {
                appBartxt = 'TAMBAH MOBIL';
              } else if (selectedItem == 'EDIT NAMA MOBIL') {
                setState(() {
                  appBartxt = 'EDIT NAMA MOBIL';
                });
              } else if (selectedItem == 'HAPUS MOBIL') {
                setState(() {
                  appBartxt = 'HAPUS MOBIL';
                });
              } else if (selectedItem == 'PILIH MOBIL') {
                setState(() {
                  appBartxt = 'PILIH MOBIL';
                });
              }
              setState(() {});
              // Tambahkan aksi yang ingin dilakukan ketika item dropdown dipilih
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _fetchData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: GestureDetector(
                onTap: () async {
                  switch (appBartxt) {
                    case 'TAMBAH MOBIL':
                      break;
                    case 'EDIT NAMA MOBIL':
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return PopupEdit(id: _fetchData[index][DatabaseHelperCar.columnId], name: _fetchData[index][DatabaseHelperCar.nameCar], database: 'mobil');
                        });
                      break;
                    case 'HAPUS MOBIL':
                      print(
                          'monitor : ${_fetchData[index][DatabaseHelperCar.columnId]}');
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PopupDelete(
                                id: _fetchData[index]
                                    [DatabaseHelperCar.columnId],
                                name: _fetchData[index]
                                    [DatabaseHelperCar.nameCar],
                                database: 'mobil',
                                    );
                          });

                      break;
                    case 'PILIH MOBIL':
                      final car = await CarDatabase.instance.read();
                      // print('monitor : ${_fetchData[index][DatabaseHelperCar.nameCar]}');
                      if (car != null) {
                        _updateData(
                            '${_fetchData[index][DatabaseHelperCar.nameCar]}',
                            '${selectedRoute}');
                      } else {
                        final insertCar = Car(
                            name:
                                '${_fetchData[index][DatabaseHelperCar.nameCar]}',
                            route: '${selectedRoute}');
                        await CarDatabase.instance.create(insertCar);
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => firstPage(),
                        ),
                      );
                      print('Monitor : data tersimpan');
                      break;
                    default:
                  }
                },
                child: ListTile(
                  title: Text(
                    _fetchData[index][DatabaseHelperCar.nameCar]
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                      _fetchData[index][DatabaseHelperCar.nameCar]
                          .toString()
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white)),
                  trailing: appBartxt == 'PILIH MOBIL'
                      ? Text('')
                      : appBartxt == 'TAMBAH MOBIL'
                          ? null
                          : appBartxt == 'EDIT NAMA MOBIL'
                              ? Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                )
                              : appBartxt == 'HAPUS MOBIL'
                                  ? Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    )
                                  : Text(''),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyMap extends StatefulWidget {
  final String condition;

  const MyMap({Key? key, required this.condition}) : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late String conditionPage;
  final Completer<GoogleMapController> _controller = Completer();

  LatLng _currentPosition = LatLng(-6.901284, 107.618705);

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isPaused = false;
  Set<Polyline> _polyLines = Set<Polyline>();
  bool pause = false;
  List<dynamic> listMapSave = [];
  Set<Marker> _markers = Set<Marker>();
  var _markersHistory = [];
  List<LatLng> polylineCoordinates = [];
  List dataLatLng = [];
  PolylinePoints? polylinePoints;
  Icon iconWidget = Icon(
    Icons.arrow_drop_up_rounded,
    color: Colors.white,
    size: 50,
  );
  bool firstFlag = true;
  bool slideBottomUp = false;

  TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    conditionPage = widget.condition;

    polylinePoints = PolylinePoints();

    _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 10))
        .listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);

      _updateCamera();
      if (conditionPage == 'tambah rute') {
        polylineCoordinates.add(_currentPosition);

        Polyline polyline = Polyline(
            polylineId: PolylineId("Polyline"),
            color: Colors.blue,
            points: polylineCoordinates);

        _polyLines.add(polyline);
        dataLatLng.add(_currentPosition);
        // print('monitor : data latlang ${dataLatLng}');
      }
      setState(() {});
    });
  }

  void _updateCamera() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 200)));
  }

  @override
  Widget build(BuildContext context) {
    _markers.add(
        Marker(markerId: MarkerId("Marker 1"), position: _currentPosition));

    Orientation orientation = MediaQuery.of(context).orientation;
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Scaffold(
        appBar: AppBar(
          title: Text('MAP MODE : ${conditionPage}'),
          leading: IconButton(
              onPressed: () {
                _positionStreamSubscription?.pause();
                conditionPage = 'normal';
                _polyLines.clear();
                setState(() {});
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded)),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, SlideLeftRoute(widget: NextPage()));
                },
                icon: Icon(Icons.more_horiz_rounded)),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              polylines: _polyLines,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                print('monitor : onMapCreated');
                /*
          
                  MENGGUNAKAN POLYLINE SESUAI JALAN MEMBUTUHKAN API GOOGLE POLYLINE
                  (BERBAYAR)
                  DAN JIKA TIDAK BISA MENGGUNAKAN SERVER PRIBADI MENGGUNAKAN OSM(OPENSTREETMAP)
          
                */
                // setPolylines();
              },
              initialCameraPosition:
                  CameraPosition(target: _currentPosition, zoom: 14.5),
              // polylines: _polyLines,
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: conditionPage == 'tambah rute'
                      ? Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: IconButton(
                                      onPressed: () {
                                        _positionStreamSubscription?.pause();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Tambah Data Rute'),
                                                actions: [
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.blue[100],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          50))),
                                                      child: IconButton(
                                                          onPressed: () {
                                                            print(
                                                                'monitor : ${_inputController.toString()}');
                                                            if (_inputController
                                                                .text.isEmpty) {
                                                              print(
                                                                  'monitor : show bottom');
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Container(
                                                                      height:
                                                                          20,
                                                                      child:
                                                                          Center(
                                                                        child: Text(
                                                                            'isi nama halte terlebih dulu'),
                                                                      ),
                                                                    );
                                                                  });
                                                              Future.delayed(
                                                                  Duration(
                                                                      milliseconds:
                                                                          1500),
                                                                  () {
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            } else {
                                                              _markers.add(
                                                                Marker(
                                                                    markerId: MarkerId(
                                                                        _inputController
                                                                            .text),
                                                                    position:
                                                                        _currentPosition,
                                                                    infoWindow:
                                                                        InfoWindow(
                                                                            title:
                                                                                _inputController.text)),
                                                              );
                                                              _markersHistory
                                                                  .add({
                                                                'markerid':
                                                                    _inputController
                                                                        .text,
                                                                'position':
                                                                    _currentPosition
                                                              });

                                                              print(
                                                                  'monitor : ${_markersHistory}');
                                                              _inputController
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          )))
                                                ],
                                                content: SingleChildScrollView(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Tambah Data Halte',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none),
                                                        ),
                                                        TextField(
                                                          controller:
                                                              _inputController,
                                                          decoration: InputDecoration(
                                                              labelText:
                                                                  'Nama Halte',
                                                              hintText:
                                                                  'Masukan Nama Halte'),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                        _positionStreamSubscription?.resume();
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: IconButton(
                                      onPressed: () {
                                        if (pause == true) {
                                          pause = false;
                                          _positionStreamSubscription?.resume();
                                        } else if (pause == false) {
                                          pause = true;
                                          setState(() {
                                            _positionStreamSubscription
                                                ?.pause();
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        pause
                                            ? Icons.play_arrow_rounded
                                            : Icons.pause_rounded,
                                        color: Colors.white,
                                      ))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: IconButton(
                                      onPressed: () {
                                        _positionStreamSubscription?.pause();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Tambah Data Rute'),
                                                actions: [
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.blue[100],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          50))),
                                                      child: IconButton(
                                                          onPressed: () {
                                                            print(
                                                                'monitor : ${_inputController.toString()}');
                                                            if (_inputController
                                                                .text.isEmpty) {
                                                              print(
                                                                  'monitor : show bottom');
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Container(
                                                                      height:
                                                                          20,
                                                                      child:
                                                                          Center(
                                                                        child: Text(
                                                                            'isi nama Rute terlebih dulu'),
                                                                      ),
                                                                    );
                                                                  });
                                                              Future.delayed(
                                                                  Duration(
                                                                      milliseconds:
                                                                          1500),
                                                                  () {
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            } else {
                                                              print(
                                                                  'monitor : dataLatLng ${dataLatLng}');
                                                              print(
                                                                  'monitor : _markersHistory ${_markersHistory}');
                                                              insertDataDir(
                                                                  _markersHistory
                                                                      .toString(),
                                                                  dataLatLng
                                                                      .toString(),
                                                                  _inputController
                                                                      .text);
                                                              print(
                                                                  'monitor : getdataDir : ${getDataDir()}');
                                                              Navigator.pop(
                                                                  context);

                                                              _inputController
                                                                  .clear();
                                                              _positionStreamSubscription
                                                                  ?.resume();
                                                              _markers.clear();
                                                              _polyLines
                                                                  .clear();
                                                              polylineCoordinates
                                                                  .clear();
                                                              conditionPage =
                                                                  'normal';
                                                              setState(() {});
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          )))
                                                ],
                                                content: SingleChildScrollView(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Simpan Data Rute',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none),
                                                        ),
                                                        TextField(
                                                          controller:
                                                              _inputController,
                                                          decoration: InputDecoration(
                                                              labelText:
                                                                  'Nama Rute',
                                                              hintText:
                                                                  'Masukan Nama Rute'),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      icon: Icon(
                                        Icons.save,
                                        color: Colors.white,
                                      ))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Text(
                                                    'Apakah anda ingin merestart data?'),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        _markers.clear();
                                                        _polyLines.clear();
                                                        polylineCoordinates
                                                            .clear();
                                                        setState(() {});
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Ya')),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('tidak')),
                                                ],
                                                content: Text(
                                                    'jika ya data yang telah terpola akan terhapus, dan memulai dari titik terbaru'));
                                          });
                                    },
                                    icon: Icon(
                                      Icons.restart_alt_rounded,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                          ],
                        )
                      : null),
            ),
          ],
        ));
  }

}

// MORE PAGE =============================================================================

class NextPage extends StatefulWidget {
  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<String> menuItems = [
    'TAMBAH RUTE',
    'EDIT NAMA RUTE',
    'HAPUS RUTE',
    'KIRIM DATA',
    'PILIH DATA RUTE'
  ];

  List<Map<String, dynamic>> _fetchData = [];

  void _getData() async {
    _fetchData = await getDataDir();
    setState(() {});
  }

  void _deleteData(int index) {
    deleteDataDir(_fetchData[index][DatabaseHelperDir.columnId]);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  String condPage = 'PILIH DATA RUTE';
  String appBartxt = 'PILIH DATA RUTE';
  bool editData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBartxt),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return menuItems.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Container(
                      color: item == appBartxt ? Colors.blue : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item,
                          style: TextStyle(
                              color: item == appBartxt
                                  ? Colors.white
                                  : Colors.blue),
                        ),
                      )),
                );
              }).toList();
            },
            onSelected: (String selectedItem) {
              if (selectedItem == 'TAMBAH RUTE') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) =>
                            MyMap(condition: 'tambah rute'))));
              } else if (selectedItem == 'EDIT NAMA RUTE') {
                setState(() {
                  appBartxt = 'EDIT NAMA RUTE';
                });
              } else if (selectedItem == 'HAPUS RUTE') {
                setState(() {
                  appBartxt = 'HAPUS RUTE';
                });
              } else if (selectedItem == 'KIRIM DATA') {
                setState(() {
                  appBartxt = 'KIRIM DATA';
                });
              } else if (selectedItem == 'PILIH DATA RUTE') {
                setState(() {
                  appBartxt = 'PILIH DATA RUTE';
                });
              }
              condPage = selectedItem;
              setState(() {});
              print('monitor : ' + condPage.toString());
              // Tambahkan aksi yang ingin dilakukan ketika item dropdown dipilih
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 50,
                height: 50,
                child: Center(
                  child: IconButton(
                      onPressed: () {
                        getDataDir();
                        print('monitor : ${_fetchData[0][DatabaseHelperDir.nameStop]}');
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => firstPage()),
                        // );
                      },
                      icon: Icon(
                        Icons.home,
                        color: Colors.blue,
                        size: 50,
                      )),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                child: Center(
                  child: Text(
                    condPage,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _fetchData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.white38; // warna saat ditekan
                              }
                              return Colors.blue;
                            })),
                            onPressed: () {
                              print('monitor : _fetchData : ${_fetchData}');
                              print('monitor : condPage = ${condPage}');
                              if (condPage == 'PILIH DATA RUTE') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            carSelect(
                                                carSelectonOutside:
                                                    'PILIH MOBIL',
                                                rute:
                                                    '${_fetchData[index][DatabaseHelperDir.nameStop]}')));
                              }
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  editData ? Container() : Text(
                                    'Halte : ${_fetchData[index][DatabaseHelperDir.nameStop]}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                  
                                  condPage == 'PILIH DATA RUTE'
                                      ? Container()
                                      : condPage == 'EDIT NAMA RUTE'
                                          ? Align(
                                              child: IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return PopupEdit(id: _fetchData[index][DatabaseHelperDir.columnId], name: _fetchData[index][DatabaseHelperDir.nameStop], database: 'rute');
                                                    });
                                                  },
                                                  icon: Icon(Icons.edit)))
                                          : condPage == 'HAPUS RUTE'
                                              ? Align(
                                                  child: IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return PopupDelete(id: _fetchData[index][DatabaseHelperDir.columnId], name: _fetchData[index][DatabaseHelperDir.nameStop], database: 'rute',);
                                                          });
                                                        setState(() {});
                                                      },
                                                      icon: Icon(Icons.delete)))
                                              : condPage == 'BATAL'
                                                  ? Container()
                                                  : condPage == 'KIRIM DATA'
                                                      ? Align(
                                                          child: IconButton(
                                                              onPressed: () {
                                                                print(
                                                                    'kirim data');

                                                                // Navigator.push(context, MaterialPageRoute(builder: ((context) => wifiPage(message: '${noCar},${jurusan}'))));
                                                              },
                                                              icon: Icon(
                                                                  Icons.send)))
                                                      : Container()
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SlideLeftRoute extends PageRouteBuilder {
  final Widget widget;

  SlideLeftRoute({required this.widget})
      : super(
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              widget,
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

class PopupEdit extends StatefulWidget {
  int id;
  String name;
  String database;

  PopupEdit({Key? key, required this.id, required this.name, required this.database}) : super(key: key);

  @override
  _PopupEditState createState() => _PopupEditState();
}

class _PopupEditState extends State<PopupEdit> {
  TextEditingController _controller = TextEditingController();
  bool _keyboardIsVisible = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('EDIT ${widget.name.toUpperCase()}'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Masukan Nama Baru'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            String text = _controller.text;
            if (widget.database == 'rute') {
              updateDataDir(widget.id, text);
            }else if(widget.database == 'mobil') {
              updateDataCar(widget.id, text);
            }
            // Do something with the entered text here
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NextPage()),
            );
          },
        ),
      ],
    );
  }
}

class PopupAdd extends StatefulWidget {
  PopupAdd({Key? key}) : super(key: key);

  @override
  _PopupAddState createState() => _PopupAddState();
}

class _PopupAddState extends State<PopupAdd> {
  TextEditingController _controller = TextEditingController();
  bool _keyboardIsVisible = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('TAMBAH MOBIL'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Masukan Nama Mobil'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            String text = _controller.text;
            // Do something with the entered text here
            insertDataCar(text);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => carSelect(
                        carSelectonOutside: 'TAMBAH MOBIL',
                        rute: '',
                      )),
            );
          },
        ),
      ],
    );
  }
}

class PopupDelete extends StatefulWidget {
  int id;
  String name;
  String database;

  PopupDelete({Key? key, required this.id, required this.name, required this.database})
      : super(key: key);

  @override
  _PopupDeleteState createState() => _PopupDeleteState();
}

class _PopupDeleteState extends State<PopupDelete> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('HAPUS ${widget.name}'),
      content: Text('Apakah anda yakin akan menghapus data ${widget.name}'),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: () {
            // Do something with the entered text here
            if (widget.database == 'mobil') {
              deleteDataCar(widget.id);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => carSelect(
                          carSelectonOutside: 'HAPUS MOBIL',
                          rute: '',
                        )),
              );
            }else if (widget.database == 'rute') {
              deleteDataDir(widget.id);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NextPage()),
              );
            }
          },
        ),
      ],
    );
  }
}

