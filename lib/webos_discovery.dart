import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebOSDiscovery {

  static const String _ssdpAddress = "239.255.255.250";
  static const int _ssdpPort = 1900;

  static const String _searchMessage =
      'M-SEARCH * HTTP/1.1\r\n'
      'HOST: 239.255.255.250:1900\r\n'
      'MAN: "ssdp:discover"\r\n'
      'MX: 3\r\n'
      'ST: urn:lge-com:service:webos-second-screen:1\r\n\r\n';

  Future<List<String>> discover({Duration timeout = const Duration(seconds: 3)}) async {
    final devices = <String>{};

    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: false,
    );

    socket.broadcastEnabled = true;

    socket.send(
      utf8.encode(_searchMessage),
      InternetAddress(_ssdpAddress),
      _ssdpPort,
    );

    final completer = Completer<List<String>>();

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final packet = socket.receive();

        if (packet == null) return;

        final message = utf8.decode(packet.data);

        if (message.contains("WebOS") ||
            message.contains("webos-second-screen")) {

          devices.add(packet.address.address);
        }
      }
    });

    Future.delayed(timeout, () {
      socket.close();
      completer.complete(devices.toList());
    });

    return completer.future;
  }
}