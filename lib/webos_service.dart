import 'dart:convert';
import 'package:pipo_controller/commands.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebOSService {
  WebSocketChannel? _main;
  WebSocketChannel? _pointer;

  bool isConnected = false;
  bool pointerReady = false;

  String? _clientKey;
  int _requestId = 1;

  Function(bool)? onConnectionChanged;
  Function(bool)? onMuteChanged;

  Future<void> connect(String ip) async {
    _main?.sink.close();
    _pointer?.sink.close();

    _main = WebSocketChannel.connect(Uri.parse("ws://$ip:3000"));

    _main!.stream.listen(_handleMessage,
        onDone: () => _updateConnection(false),
        onError: (_) => _updateConnection(false));

    await _loadClientKey();
    _sendPairing();
  }

  void _updateConnection(bool state) {
    isConnected = state;
    pointerReady = false;
    onConnectionChanged?.call(state);
  }

  void _handleMessage(dynamic message) {
    final data = jsonDecode(message);
    if (data['type'] == 'registered') {
      _clientKey = data['payload']['client-key'];
      _saveClientKey(_clientKey!);
      _updateConnection(true);
      _requestPointer();
      requestMuteStatus();
    } else if (data['payload']?['socketPath'] != null) {
      _pointer = WebSocketChannel.connect(
        Uri.parse(data['payload']['socketPath']),
      );
      pointerReady = true;
    } else if (data['type'] == 'response' &&
        data['payload']?['mute'] != null) {
      onMuteChanged?.call(data['payload']['mute']);
    }
  }

  Future<void> _loadClientKey() async {
    final prefs = await SharedPreferences.getInstance();
    _clientKey = prefs.getString("client_key");
  }

  Future<void> _saveClientKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("client_key", key);
  }

  void _sendPairing() {
    final payload = {
      "type": "register",
      "id": "register_0",
      "payload": {
        "pairingType": "PROMPT",
        "client-key": _clientKey,
        "manifest": {
          "manifestVersion": 1,
          "permissions": [
            "CONTROL_AUDIO",
            "CONTROL_DISPLAY",
            "CONTROL_INPUT_JOYSTICK",
            "CONTROL_MOUSE_AND_KEYBOARD",
            "READ_POWER_STATE"
          ]
        }
      }
    };

    _main?.sink.add(jsonEncode(payload));
  }

  void _requestPointer() {
    send("ssap://com.webos.service.networkinput/getPointerInputSocket");
  }

  void send(String uri, [Map<String, dynamic>? payload]) {
    if (!isConnected) return;

    final request = {
      "id": "req_${_requestId++}",
      "type": "request",
      "uri": uri,
      "payload": ?payload,
    };

    _main?.sink.add(jsonEncode(request));
  }

  void sendPointer(String key) {
    if (!pointerReady) return;

    _pointer?.sink.add(
        "type:button\nname:$key\n\n"
    );
  }

  void goHome() {
    send("ssap://system.launcher/open");
  }

  void requestMuteStatus() {
    send(Commands.getMute);
  }

  void dispose() {
    _main?.sink.close();
    _pointer?.sink.close();
  }
}