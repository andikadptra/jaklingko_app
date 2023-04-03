import 'dart:io';
import 'package:flutter/material.dart';

class wifiPage extends StatefulWidget {
  final String message;

  const wifiPage({Key? key, required this.message}) : super(key: key); 

  @override
  _wifiPageState createState() => _wifiPageState(message);
}

class _wifiPageState extends State<wifiPage> {
  final String _message;

  _wifiPageState(this._message);

  final _hostController = TextEditingController();
  final _portController = TextEditingController();

  String _response = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UDP Communication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _hostController,
              decoration: InputDecoration(
                labelText: 'Host',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Port',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            Text('Send Message Text : ${_message}'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String host = _hostController.text;
                int port = int.tryParse(_portController.text) ?? 0;

                // Create a UDP socket
                var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

                // Listen for incoming data
                socket.listen((event) {
                  if (event == RawSocketEvent.read) {
                    Datagram? datagram = socket.receive();
                    if (datagram != null) {
                      setState(() {
                        _response = String.fromCharCodes(datagram.data).trim();
                      });
                    }
                  }
                });

                // Send a message to the server
                String message = _message.toString();
                socket.send(message.codeUnits, InternetAddress(host), port);
              },
              child: Text('Send Message'),
            ),
            SizedBox(height: 16.0),
            Text('Response: $_response'),
          ],
        ),
      ),
    );
  }
}
