import 'package:flutter/material.dart';
import 'package:pipo_controller/webos_discovery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipo_controller/webos_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'commands.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final discovery = WebOSDiscovery();

  final devices = await discovery.discover();

  print("Found: $devices");

  await Future.delayed(const Duration(seconds: 1));

  runApp(const PipoControllerApp());
}

class PipoControllerApp extends StatelessWidget {
  const PipoControllerApp({super.key});

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

class _RemoteScreenState extends State<RemoteScreen>
    with WidgetsBindingObserver {
  final WebOSService _service = WebOSService();
  bool _isConnected = false;
  final TextEditingController _ipController = TextEditingController();
  String _status = "Disconnected";
  bool _isMuted = false;
  Timer? _holdTimer;
  DateTime? _holdStart;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("Lifecycle: $state");

    if (state == AppLifecycleState.resumed) {
      _reconnectIfNeeded();
    }
  }

  Future<bool> _onBackPressed() async {
    SystemNavigator.pop();
    return false;
  }

  void _handleBack() {
    SystemNavigator.pop();
  }

  Future<void> _reconnectIfNeeded() async {
    if (_isConnected) return;

    final prefs = await SharedPreferences.getInstance();
    final lastIp = prefs.getString('last_ip');

    if (lastIp != null) {
      print("Reconnecting automatically...");
      _service.connect(lastIp);
    }
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

  void _hapticTick() {
    HapticFeedback.vibrate();
  }

  Duration _currentRepeatDelay() {
    final heldMs = DateTime.now().difference(_holdStart!).inMilliseconds;

    if (heldMs < 300) {
      return const Duration(milliseconds: 220); // low start
    } else if (heldMs < 1000) {
      return const Duration(milliseconds: 140); // medium progress
    } else {
      return const Duration(milliseconds: 70); // fast progress
    }
  }

  void _startHold(VoidCallback action) {
    _holdStart = DateTime.now();

    action();
    _hapticTick();

    void scheduleNext() {
      _holdTimer = Timer(_currentRepeatDelay(), () {
        action();
        _hapticTick();
        scheduleNext();
      });
    }

    scheduleNext();
  }

  void _simpleClick(VoidCallback action) {
    action();
    _hapticTick();
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
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
                  Text(_status, style: TextStyle(color: _isConnected ? Colors.green : Colors.red)),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _btn(Icons.power_settings_new, Colors.red,
                              () => _service.send(Commands.turnOff),
                          size: 30,
                          padding: const EdgeInsets.all(10),
                          enableHold: false),
                      const SizedBox(width: 140), // Placeholder to keep layout balanced
                    ],
                  ),

                  const SizedBox(height: 30),
                  _buildDPad(),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _rocker("VOL", Icons.add, Icons.remove,
                              () => _service.send(Commands.volumeUp),
                              () => _service.send(Commands.volumeDown)),
                      _btn(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          _isMuted ? Colors.red : Colors.grey[800]!,
                          size: 30,
                          padding: const EdgeInsets.all(10),
                          _toggleMute,
                          enableHold: false
                      ),
                      _rocker("CH", Icons.keyboard_arrow_up, Icons.keyboard_arrow_down,
                              () => _service.send(Commands.channelUp),
                              () => _service.send(Commands.channelDown)),
                    ],
                  ),

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _btn(Icons.home, const Color(0xFFA50034),
                              () => openHome(), size: 25,
                              padding: const EdgeInsets.all(10),
                              enableHold: false),
                      _btn(Icons.exit_to_app, Colors.grey[800]!,
                              () => _service.sendPointer("EXIT"),
                              size: 25,
                              padding: const EdgeInsets.all(10),
                              enableHold: false),
                    ],
                  ),
                ],
              ),
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
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text("RECENTS"),
              ),
            ),
            const SizedBox(width: 20),
            _btn(Icons.keyboard_arrow_up, Colors.grey[900]!, () => _service.sendPointer("UP")),
            const SizedBox(width: 20),
            _btn(Icons.arrow_back, Colors.grey[800]!, () =>  _service.sendPointer("BACK"), enableHold: false),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btn(Icons.keyboard_arrow_left, Colors.grey[900]!, () => _service.sendPointer("LEFT")),
            const SizedBox(width: 20),
            _btn(Icons.circle, Colors.grey[800]!, () => _service.sendPointer("ENTER"), enableHold: false),
            const SizedBox(width: 20),
            _btn(Icons.keyboard_arrow_right, Colors.grey[900]!, () => _service.sendPointer("RIGHT")),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20)
          ],
        ),
        _btn(Icons.keyboard_arrow_down, Colors.grey[900]!, () => _service.sendPointer("DOWN")),
      ],
    );
  }

  Widget _btn(
      IconData icon,
      Color color,
      VoidCallback onTap, {
        bool enableHold = true,
        double size = 30,
        EdgeInsets padding = const EdgeInsets.all(16),
        ShapeBorder shape = const CircleBorder(),
      }) {
    return Material(
      color: color,
      shape: shape,
      elevation: 4,
      child: InkWell(
        customBorder: shape,

        onTap: !enableHold ? () => _simpleClick(onTap) : null,

        onTapDown: enableHold ? (_) => _startHold(onTap) : null,
        onTapUp: enableHold ? (_) => _stopHold() : null,
        onTapCancel: enableHold ? _stopHold : null,

        child: Padding(
          padding: padding,
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _rocker(
      String label,
      IconData up,
      IconData down,
      VoidCallback onUp,
      VoidCallback onDown,
      ) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 130,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => _startHold(onUp),
                  onTapUp: (_) => _stopHold(),
                  onTapCancel: _stopHold,
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => _startHold(onDown),
                  onTapUp: (_) => _stopHold(),
                  onTapCancel: _stopHold,
                  child: const Center(
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
              ),
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