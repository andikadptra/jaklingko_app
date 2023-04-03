import 'dart:convert';
import 'dart:io';
import 'package:wifi_iot/wifi_iot.dart';

class UdpSender {
  static const int SERVER_PORT = 1234; // Port number of the receiver
  static const int UDP_PORT = 4321; // Port number to use for sending the data

  Future<void> sendMessage(String message, String ssid, String password) async {
    // Connect to the selected WiFi network
    await WiFiForIoTPlugin.connect(ssid, password: password, joinOnce: true);

    // Get the IP address of the connected device
    String? ipAddress = await WiFiForIoTPlugin.getIP();

    if (await WiFiForIoTPlugin.isConnected()) {
     // Create a UDP socket
    RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, UDP_PORT);

    // Encode the message into a list of bytes
    List<int> messageBytes = utf8.encode(message);

    // Send the message to the receiver
    socket.send(messageBytes, InternetAddress(ipAddress!), SERVER_PORT);

    // Close the socket
    socket.close(); 
    }
  }
}
