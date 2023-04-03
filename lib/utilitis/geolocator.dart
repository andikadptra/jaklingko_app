import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:app_settings/app_settings.dart';
import 'package:open_app_settings/open_app_settings.dart';

class LocationStream extends StatefulWidget {
  @override
  State<LocationStream> createState() => _LocationStreamState();
}

class _LocationStreamState extends State<LocationStream> {
  TextStyle myTextStyle(double size, FontWeight fW) {
    // Definisikan style teks yang ingin Anda kembalikan
    TextStyle myTextStyle =
        TextStyle(fontSize: size, color: Colors.white, fontWeight: fW);

    // Kembalikan style teks
    return myTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
      stream: Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 10)),
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text('buka app settings, dan izin kan lokasi!',
                  style: TextStyle(color: Colors.red)),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text('Mengambil Lokasi',
                  style: myTextStyle(16, FontWeight.w400)),
            ),
          );
        }

        final position = snapshot.data;
        final latitude = position?.latitude;
        final longitude = position?.longitude;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text('LAT : ${latitude}',
                    style: myTextStyle(16, FontWeight.w400))),
            Expanded(
                child: Text('LON : ${longitude}',
                    style: myTextStyle(16, FontWeight.w400))),
          ],
        );
      },
    );
  }
}

class speedStream extends StatefulWidget {
  speedStream({Key? key}) : super(key: key);

  @override
  State<speedStream> createState() => _speedStreamState();
}

class _speedStreamState extends State<speedStream> {
  TextStyle myTextStyle(double size, FontWeight fW) {
    // Definisikan style teks yang ingin Anda kembalikan
    TextStyle myTextStyle =
        TextStyle(fontSize: size, color: Colors.white, fontWeight: fW);

    // Kembalikan style teks
    return myTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
      stream: Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 10)),
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Center(
              child: Center(child: ElevatedButton(onPressed: () {
                AppSettings.openAppSettings();
              }, child: Text('Izinkan Aplikasi'))),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Center(
              child: Text('Mengambil Data...',
                  style: myTextStyle(16, FontWeight.w400)),
            ),
          );
        }

        final data = snapshot.data!.speed;
        double _speed = data * 3.6;

        return Container(
            child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_speed.toStringAsFixed(2)}',
                style: myTextStyle(50, FontWeight.w900),
              ),
              Text(
                'KM/JAM',
                style: myTextStyle(12, FontWeight.w500),
              ),
            ],
          ),
        ));
      },
    );
  }
}
