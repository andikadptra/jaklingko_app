import 'package:driver_app/components/constants.dart';
import 'package:driver_app/database/database_helper_dir.dart';
import 'package:driver_app/utilitis/utilitis_database_dir.dart';
import 'package:driver_app/page/wifi_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart';

class carSelect extends StatefulWidget {
  const carSelect({Key? key}) : super(key: key);

  @override
  State<carSelect> createState() => _carSelectState();
}

class _carSelectState extends State<carSelect> {
  TextEditingController _controller = TextEditingController();
  bool _keyboardIsVisible = false;

  List<String> menuItems = [
    'TAMBAH MOBIL',
    'EDIT NAMA MOBIL',
    'HAPUS MOBIL',
    'PILIH MOBIL'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List sampleData = [
    {
      'columnId' : 1, 
      'nameCar' : 'A10',
    }
  ];
  

  String appBartxt = 'PILIH MOBIL';

  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: appBartxt == 'TAMBAH MOBIL' ? FloatingActionButton.extended(onPressed: () {
        showDialog(context: context, builder: (BuildContext context) {
          return PopupAdd();
        });
      }, label: Text('TAMBAH'),) : null,
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
        itemCount: sampleData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: GestureDetector(
                onTap: () {
                  switch (appBartxt) {
                    case 'PILIH MOBIL':
                      null;
                      break;
                    case 'TAMBAH MOBIL':

                      break;
                    case 'EDIT NAMA MOBIL':
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PopupEdit(id: sampleData[index]['columnId'], name: sampleData[index]['nameCar'],);
                          });
                      break;
                    case 'HAPUS MOBIL':
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PopupDelete(id: sampleData[index]['columnId'], name: sampleData[index]['nameCar'],);
                          });
                      break;
                    default:
                  }
                },
                child: ListTile(
                  title: Text(
                    'A01',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text('A02', style: TextStyle(color: Colors.white)),
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

  // void setPolylines() async {
  //   print('Monitor : setPolylines');
  //   PolylineResult result = await polylinePoints!.getRouteBetweenCoordinates(
  //       "AIzaSyDr54SJAd8woqkYBK_PQhFZr5c3ocdXTOI",
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(
  //           destinationLocation.latitude, destinationLocation.longitude));
  //   print('Monitor : result status = ${result.status}');
  //   if (result.status == "OK") {
  //     print('Monitor : ok');
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });

  //     setState(() {
  //       _polyLines.add(Polyline(
  //           width: 10,
  //           polylineId: PolylineId("Polyline"),
  //           color: Colors.blue,
  //           points: polylineCoordinates));
  //       print("monitor : ${_polyLines}");
  //     });
  //   }
  // }
}

// more page

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

  List<Map<String, dynamic>> fetchData = [];

  void _fetchData() async {
    fetchData = await getDataDir();
    setState(() {});
  }

  void _deleteData(int index) {
    deleteDataDir(fetchData[index][DatabaseHelper.columnId]);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
  }

  String condPage = 'DATA RUTE';
  String appBartxt = 'PILIH DATA RUTE';

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
      body: Column(
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
                itemCount: fetchData.length,
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
                          print('monitor : fetchdata : ${fetchData}');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      carSelect()));
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Halte : ${fetchData[index][DatabaseHelper.nameStop]}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                              condPage == 'DATA RUTE'
                                  ? Container()
                                  : condPage == 'EDIT NAMA RUTE'
                                      ? Align(
                                          child: IconButton(
                                              onPressed: () {
                                                // Navigator.push(context, MaterialPageRoute(builder: ((context) => wifiPage(message: '${noCar},${jurusan}'))));
                                              },
                                              icon: Icon(Icons.edit)))
                                      : condPage == 'HAPUS RUTE'
                                          ? Align(
                                              child: IconButton(
                                                  onPressed: () {
                                                    print(
                                                        'monitor : ${fetchData[index][DatabaseHelper.columnId]}');
                                                    _deleteData(index);
                                                    Navigator.pop(context);
                                                    setState(() {});
                                                  },
                                                  icon: Icon(Icons.delete)))
                                          : condPage == 'BATAL'
                                              ? Container()
                                              : condPage == 'KIRIM DATA'
                                                  ? Align(
                                                      child: IconButton(
                                                          onPressed: () {
                                                            // fungsi simpan data ke mysql lite database user

                                                            // Navigator.push(context, MaterialPageRoute(builder: ((context) => wifiPage(message: '${noCar},${jurusan}'))));
                                                          },
                                                          icon:
                                                              Icon(Icons.send)))
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

  PopupEdit({Key? key, required this.id, required this.name}) : super(key: key);
  

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
      title: Text('EDIT ${widget.name}'),
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
            // Do something with the entered text here
            Navigator.of(context).pop();
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class PopupDelete extends StatefulWidget {
  int id;
  String name;

  PopupDelete({Key? key, required this.id, required this.name}) : super(key: key);
  

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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}