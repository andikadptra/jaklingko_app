// ignore_for_file: depend_on_referenced_packages, camel_case_types

import 'package:driver_app/page/maps_page.dart';
import 'package:driver_app/page/wifi_page.dart';
import 'package:driver_app/database/database_helper_user.dart';
import 'package:driver_app/utilitis/wifi_communicate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/utilitis/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:network_info_plus/network_info_plus.dart';

class firstPage extends StatefulWidget {
  const firstPage({Key? key}) : super(key: key);

  @override
  State<firstPage> createState() => _firstPageState();
}

class _firstPageState extends State<firstPage> {
  final FlutterTts flutterTts = FlutterTts();
  String rute = '';
  String car = '';
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String currentTime = DateFormat('HH:mm').format(DateTime.now());
  String statusCar = '-';
  String displayText = '-';
  String soundName = '001';
  String latitude = 'XXXXXXX';
  String longitude = 'XXXXXXX';
  String cog = 'XXXXXXX';
  String sat = 'XX';
  bool check = true;
  int speed = 10;
  var savedCar;

  getDataUser() {
    final carDb = CarDatabase.instance;

    catchDb() async {
      savedCar = await CarDatabase.instance.read();
    }

    if (check) {
      catchDb();
      if (savedCar != null) {
        setState(() {
          car = savedCar!.name;
          rute = savedCar!.route;
        });
      }
    }
  }

  @override
  Future<bool> handleLocationPermission() async {
    String locationDen = 'Buka pengaturan, dan izinkan Lokasi!';
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  TextStyle myTextStyle(double size, FontWeight fW) {
    // Definisikan style teks yang ingin Anda kembalikan
    TextStyle myTextStyle =
        TextStyle(fontSize: size, color: Colors.white, fontWeight: fW);

    // Kembalikan style teks
    return myTextStyle;
  }

  Future speak(String message) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    String timeNow = '${currentDate} ${currentTime}';

    getDataUser();

    // bool audioPlay = false;
    Orientation orientation = MediaQuery.of(context).orientation;
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          // final savedCar = await CarDatabase.instance.read();
          // final carDatabase = CarDatabase.instance;
          // final car = await carDatabase.read();

          // final name = car!.route;
          // print('monitor ${name}');
          setState(() {
            print('monitor : ${car}');
          });

          // final cars = await CarDatabase.instance.readAll();
          // cars.forEach((car) {
          //   print('monitor : ${car.toJson()}');
          // });
        },
        child: Icon(
          Icons.restart_alt,
          color: Colors.blue,
        ),
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: widthScreen,
          height: heightScreen,
          child: Row(
            children: [
              // infomration bar
              Container(
                width: widthScreen / 2,
                height: heightScreen,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 5),
                        spreadRadius: 5,
                        blurRadius: 20,
                      ),
                    ],
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
                child: Column(
                  children: [
                    Container(
                      // height: heightScreen * 0.13,
                      child: Row(
                        children: [
                          Container(
                            width: widthScreen / 2 * 0.3,
                            height: heightScreen * 0.25,
                            color: Colors.white,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                    height: heightScreen * 0.13,
                                    width: widthScreen * 0.3,
                                    color: Colors.blue,
                                    child: Center(
                                      child: Text(
                                        'B10',
                                        style: myTextStyle(20, FontWeight.bold),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          Container(
                            width: widthScreen / 2 * 0.7,
                            height: heightScreen * 0.25,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                  color: Colors.blue,
                                  width: widthScreen * 0.7,
                                  height: heightScreen * 0.13,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('TGL : ${timeNow}',
                                            style: myTextStyle(
                                                16, FontWeight.w500)),
                                        Expanded(child: LocationStream()),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text('COG : ${cog}',
                                                    style: myTextStyle(
                                                        16, FontWeight.w400))),
                                            Expanded(
                                                child: Text('SAT : ${sat}',
                                                    style: myTextStyle(
                                                        16, FontWeight.w400))),
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'RUTE : ${savedCar != null ? car.toUpperCase() : ''} - ${savedCar != null ? rute.toUpperCase() : ''}',
                              style: myTextStyle(18, FontWeight.w500),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 10),
                              child: Column(
                                children: [
                                  Text(
                                    'KECEPATAN GPS',
                                    style: myTextStyle(25, FontWeight.w700),
                                  ),
                                  speedStream()
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text('STATUS : ${statusCar}',
                                      style: myTextStyle(16, FontWeight.w500)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text('DISPLAY : ${displayText}',
                                      style: myTextStyle(16, FontWeight.w400)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text('SOUND : ${soundName}',
                                      style: myTextStyle(16, FontWeight.w400)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // button bar
              Container(
                width: widthScreen / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            print('pindah rute');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        MyMap(condition: 'normal'))));
                          },
                          child: Container(
                            width: widthScreen,
                            height: 50,
                            child: Center(
                              child: Text('PILIH RUTE'),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            await speak(
                                "Mulai perjalanan, tetap fokus dan hati hati dijalan");
                                statusCar = 'DALAM PERJALANAN';
                                displayText = 'SEDANG DALAM PERJALANAN';
                            await flutterTts.awaitSpeakCompletion(true);
                            setState(() {});
                          },
                          child: Container(
                            width: widthScreen,
                            height: 50,
                            child: Center(
                              child: Text('START'),
                            ),
                          )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                await speak("Sedang Mengisi BBM");
                                setState(() {
                                  statusCar = 'ISI BBM';
                                  displayText = 'MAAF SEDANG MENGISI BBM';
                                });
                                await flutterTts.awaitSpeakCompletion(true);
                                print("Speech selesai");
                              },
                              child: Container(
                                width: widthScreen / 2 / 2.7,
                                height: 50,
                                child: Center(
                                  child: Text('ISI BBM'),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                String result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MyDialog();
                                  },
                                );

                                // Lakukan aksi berdasarkan hasil yang dipilih oleh pengguna
                                if (result == '1') {
                                  statusCar = 'PERJALANAN PULANG';
                                  await speak("Mobil perjalanan pulang");
                                } else if (result == '2') {
                                  statusCar = 'PERJALANAN PERGI';
                                  await speak("Mobil perjalanan pergi");
                                }

                                setState(() {
                                  displayText =
                                      'MOBIL SEDANG ${statusCar.toUpperCase()}';
                                });
                                await flutterTts.awaitSpeakCompletion(true);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => wifiPage(
                                            message: 'Perjalanan pulang'))));
                              },
                              child: Container(
                                width: widthScreen / 2 / 2.7,
                                height: 50,
                                child: Center(
                                  child: Text('PERGI / PULANG'),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                /*
                                 SEND STRING TO WIFI
                                 MASUKAN NAMA SSID DAN PASSWORDNYA!
                                */

                                await speak("mematikan TiVi");
                                await flutterTts.awaitSpeakCompletion(true);
                                final info = NetworkInfo();
                                final ssid = '';
                                final password = '';
                                UdpSender().sendMessage(
                                    'Mematikan TV', ssid, password);
                              },
                              child: Container(
                                width: widthScreen / 2 / 2.7,
                                height: 50,
                                child: Center(
                                  child: Text('OFF TV'),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                await speak(
                                    "Selamat datang penumpang, silahkan untuk menempati tempat duduk yang kosong");
                                setState(() {
                                  statusCar = 'SELAMAT DATANG';
                                  displayText =
                                      'SELAMAT DATANG PENUMPANG SETIA';
                                });
                                await flutterTts.awaitSpeakCompletion(true);
                              },
                              child: Container(
                                width: widthScreen / 2 / 2.7,
                                height: 50,
                                child: Center(
                                  child: Text('SELAMAT DATANG'),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                await speak("sistem tes");
                                await flutterTts.awaitSpeakCompletion(true);
                              },
                              child: Container(
                                width: widthScreen / 2 / 2.7,
                                height: 50,
                                child: Center(
                                  child: Text('SISTEM TES'),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                await speak("wiu wiu wiu wiu");
                                await flutterTts.awaitSpeakCompletion(true);
                              },
                              child: Container(
                                width: widthScreen / 2 / 2.7,
                                height: 50,
                                child: Center(
                                  child: Text('PANIC BUTTON'),
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({Key? key}) : super(key: key);

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final FlutterTts flutterTts = FlutterTts();

  Future speak(String message) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('PERJALANAN'),
      content: Text('PILIH KONDISI PERJALANAN'),
      actions: <Widget>[
        TextButton(
          child: Text('PERJALANAN PULANG'),
          onPressed: () async {
            Navigator.pop(context, '1');
          },
        ),
        TextButton(
          child: Text('PERJALANAN PERGI'),
          onPressed: () async {
            Navigator.pop(context, '2');
          },
        ),
      ],
    );
  }
}
