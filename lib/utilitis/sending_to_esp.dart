import 'dart:convert';
import 'dart:io';

Future<void> sendDataToESP32(String dataToSend, alamat_ip, int port_server) async {
  final socket = await Socket.connect(alamat_ip, port_server);
  socket.write(dataToSend);
  await socket.flush();
  await socket.close();
}