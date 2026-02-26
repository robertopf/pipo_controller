import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipo_controller/webos_service.dart';
import 'dart:async';

import 'commands.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.delayed(const Duration(seconds: 1));

  runApp(const LGControllerApp());
}

class LGControllerApp extends StatelessWidget {
  const LGControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LG WebOS Remote Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFA50034),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA50034),
          secondary: Color(0xFFA50034),
        ),
      ),
      home: const RemoteScreen(),
    );
  }
}

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final WebOSService _service = WebOSService();
  bool _isConnected = false;
  final TextEditingController _ipController = TextEditingController();
  String _status = "Disconnected";
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();

    _service.onConnectionChanged = (state) {
      setState(() {
        _isConnected = state;
        _status = state ? "Connected" : "Disconnected";
      });
    };

    _service.onMuteChanged = (state) {
      setState(() {
        _isMuted = state;
      });
    };

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIp = prefs.getString('last_ip');
    if (lastIp != null) {
      _ipController.text = lastIp;
      _connect(lastIp);
    }
  }

  Future<void> _connect(String ip) async {
    setState(() => _status = "Connecting...");
    await _service.connect(ip);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_ip', ip);
  }

  void openHome() {
    _service.sendPointer("HOME");
  }

  void _toggleMute() {
    _isMuted = !_isMuted;
    _service.send(Commands.setMute, {"mute": _isMuted});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link : Icons.link_off,
                color: _isConnected ? Colors.green : Colors.red),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn(Icons.power_settings_new, Colors.red, () => _service.send(Commands.turnOff)),
                  _btn(Icons.arrow_back, Colors.grey[800]!, () =>  _service.sendPointer("BACK")),
                ],
              ),

              const SizedBox(height: 40),
              _buildDPad(),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _rocker("VOL", Icons.add, Icons.remove,
                          () => _service.send(Commands.volumeUp),
                          () => _service.send(Commands.volumeDown)),
                  _btn(Icons.home, const Color(0xFFA50034), () => openHome()),
                  _rocker("CH", Icons.keyboard_arrow_up, Icons.keyboard_arrow_down,
                          () => _service.send(Commands.channelUp),
                          () => _service.send(Commands.channelDown)),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      _isMuted ? Colors.red : Colors.grey[800]!,
                      _toggleMute
                  ),
                  _btn(Icons.exit_to_app, Colors.grey[800]!, () => _service.sendPointer("EXIT")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: openHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text("RECENTS"),
              ),
            ),
            const SizedBox(width: 20),
            _btn(Icons.keyboard_arrow_up, Colors.grey[900]!, () => _service.sendPointer("UP")),
            const SizedBox(width: 100), // Placeholder to keep layout balanced
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btn(Icons.keyboard_arrow_left, Colors.grey[900]!, () => _service.sendPointer("LEFT")),
            const SizedBox(width: 20),
            _btn(Icons.circle, Colors.grey[800]!, () => _service.sendPointer("ENTER")),
            const SizedBox(width: 20),
            _btn(Icons.keyboard_arrow_right, Colors.grey[900]!, () => _service.sendPointer("RIGHT")),
          ],
        ),
        _btn(Icons.keyboard_arrow_down, Colors.grey[900]!, () => _service.sendPointer("DOWN")),
      ],
    );
  }

  Widget _btn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _rocker(String label, IconData up, IconData down, VoidCallback onUp, VoidCallback onDown) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
          child: Column(
            children: [
              IconButton(onPressed: onUp, icon: Icon(up, color: Colors.white)),
              const SizedBox(height: 5, child: Divider(color: Colors.white10)),
              IconButton(onPressed: onDown, icon: Icon(down, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("TV Setup"),
        content: TextField(
          controller: _ipController,
          decoration: const InputDecoration(labelText: "TV IP Address"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { _connect(_ipController.text); Navigator.pop(context); }, child: const Text("Connect")),
        ],
      ),
    );
  }
}