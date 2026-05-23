// PHINO - File Sharing App | by Galib
// Built with Flutter — Android & iOS
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:dio/dio.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart' as open_filex;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as p;

// App entry point | by Galib
void main() {
  runApp(const FileShareApp());
}

class FileShareApp extends StatelessWidget {
  const FileShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PHINO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF1C1C2E),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// Splash Screen with Animation
// ─────────────────────────────────────────────
// Splash screen with animations | by Galib
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Logo scale-in
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    // Fade in
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Text slide up
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Pulse glow
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Sequence animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _slideController.forward();
    });

    // Navigate to home after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const HomePage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.05), end: Offset.zero)
                      .animate(animation),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing glow behind logo
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) {
                  return Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF)
                              .withOpacity(0.3 * _pulseAnim.value),
                          blurRadius: 60 * _pulseAnim.value,
                          spreadRadius: 20 * _pulseAnim.value,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C2E),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.4),
                          width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.swap_horiz_rounded,
                          color: Color(0xFF6C63FF), size: 72),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // App name + tagline slide up
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _slideController,
                  child: Column(
                    children: [
                      const Text(
                        'PHINO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share files. Instantly.',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Developed by Galib',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Loading dots
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _slideController,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final delay = i * 0.3;
                          final val = (_pulseController.value - delay).clamp(0.0, 1.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF6C63FF)
                                  .withOpacity(0.3 + 0.7 * val),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Local WiFi server port | by Galib
const int kServerPort = 8765;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  String _deviceModel = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceModel();
  }

  Future<void> _loadDeviceModel() async {
    final info = DeviceInfoPlugin();
    String model = '';
    try {
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        model = android.model;
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        model = ios.name;
      }
    } catch (_) {}
    if (mounted) setState(() => _deviceModel = model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        title: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6C63FF), size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PHINO',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2)),
                if (_deviceModel.isNotEmpty)
                  Text(_deviceModel,
                      style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                const Text('Developed by Galib',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: 'Send',
                  icon: Icons.upload_rounded,
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _TabButton(
                  label: 'Receive',
                  icon: Icons.download_rounded,
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTab == 0 ? const SendTab() : const ReceiveTab(),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEND TAB
// ─────────────────────────────────────────────
// Send Tab — select & share multiple files over WiFi | by Galib
class SendTab extends StatefulWidget {
  const SendTab({super.key});

  @override
  State<SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  List<PlatformFile> _selectedFiles = [];
  HttpServer? _server;
  bool _isServing = false;
  String _myIp = '';
  String _statusMessage = 'Select files to share';

  @override
  void dispose() {
    _stopServer();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage, Permission.manageExternalStorage].request();
  }

  Future<void> _pickFiles() async {
    await _requestPermissions();
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      await _stopServer();
      setState(() {
        _selectedFiles = result.files;
        _isServing = false;
        _statusMessage = '${result.files.length} file(s) selected. Tap "Start Sharing".';
      });
    }
  }

  // Starts local HTTP server to serve files | by Galib
  Future<void> _startServer() async {
    if (_selectedFiles.isEmpty) return;

    final router = shelf_router.Router();

    // List all files
    router.get('/list', (shelf.Request req) {
      final list = _selectedFiles.map((f) => {'name': f.name, 'size': f.size}).toList();
      return shelf.Response.ok(jsonEncode(list), headers: {'Content-Type': 'application/json'});
    });

    // Download file by index
    router.get('/file/<index>', (shelf.Request req, String index) {
      final i = int.tryParse(index) ?? 0;
      if (i < 0 || i >= _selectedFiles.length) return shelf.Response.notFound('Not found');
      final file = _selectedFiles[i];
      final stream = File(file.path!).openRead();
      return shelf.Response.ok(stream, headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': 'attachment; filename="${file.name}"',
        'Content-Length': '${file.size}',
      });
    });

    final handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(router.call);
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, kServerPort);

    final info = NetworkInfo();
    _myIp = await info.getWifiIP() ?? 'Unknown';

    setState(() {
      _isServing = true;
      _statusMessage = 'Sharing ${_selectedFiles.length} file(s)...';
    });
  }

  Future<void> _stopServer() async {
    await _server?.close(force: true);
    _server = null;
    if (mounted) {
      setState(() {
        _isServing = false;
        _statusMessage = _selectedFiles.isEmpty
            ? 'Select files to share'
            : '${_selectedFiles.length} file(s) selected. Tap "Start Sharing".';
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Selected Files',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (_selectedFiles.isNotEmpty)
                      Text('${_selectedFiles.length} file(s)',
                          style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedFiles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(children: [
                        Icon(Icons.insert_drive_file_outlined, color: Colors.white24, size: 48),
                        SizedBox(height: 8),
                        Text('No files selected', style: TextStyle(color: Colors.white38)),
                      ]),
                    ),
                  )
                else
                  ..._selectedFiles.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF6C63FF), size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(f.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                              Text(_formatSize(f.size),
                                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ]),
                          ),
                        ]),
                      )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isServing ? null : _pickFiles,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Browse Files (Multiple)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                    _isServing ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded,
                    color: _isServing ? const Color(0xFF00E676) : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_statusMessage,
                        style: TextStyle(
                            color: _isServing ? const Color(0xFF00E676) : Colors.white54,
                            fontSize: 13)),
                  ),
                ]),
                if (_isServing) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0F0F1A), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.link, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('$_myIp',
                            style: const TextStyle(
                                color: Colors.white70, fontFamily: 'monospace', fontSize: 16)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF6C63FF), size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _myIp));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('IP copied!'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  const Text('Share this IP with the receiver',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _selectedFiles.isEmpty ? null : (_isServing ? _stopServer : _startServer),
              icon: Icon(_isServing ? Icons.stop_rounded : Icons.share_rounded),
              label: Text(_isServing ? 'Stop Sharing' : 'Start Sharing',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isServing ? Colors.redAccent : const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _InfoBox(
            icon: Icons.info_outline_rounded,
            text: 'Both devices must be on the same WiFi. The receiver will enter your IP address to connect.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECEIVE TAB
// ─────────────────────────────────────────────
// Receive Tab — connect via IP and download files | by Galib
class ReceiveTab extends StatefulWidget {
  const ReceiveTab({super.key});

  @override
  State<ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<ReceiveTab> {
  final TextEditingController _ipController = TextEditingController();
  List<Map<String, dynamic>> _fileList = [];
  bool _isConnecting = false;
  bool _isConnected = false;
  String _statusMessage = '';
  Map<int, double> _progress = {};
  Map<int, String> _savedPaths = {};

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  // Connects to sender's HTTP server using IP | by Galib
  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    setState(() {
      _isConnecting = true;
      _fileList = [];
      _isConnected = false;
      _statusMessage = 'Connecting...';
      _progress = {};
      _savedPaths = {};
    });
    try {
      final response = await Dio().get('http://$ip:$kServerPort/list').timeout(const Duration(seconds: 5));
      final list = (response.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _fileList = list;
        _isConnected = true;
        _isConnecting = false;
        _statusMessage = 'Connected! ${list.length} file(s) ready.';
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _statusMessage = 'Could not connect. Check IP and try again.';
      });
    }
  }

  // Downloads a specific file by index from sender | by Galib
  Future<void> _downloadFile(int index) async {
    final ip = _ipController.text.trim();
    final fileName = _fileList[index]['name'] ?? 'file_$index';
    final dir = await getApplicationDocumentsDirectory();
    final savePath = p.join(dir.path, fileName);
    setState(() {
      _progress[index] = 0;
      _savedPaths.remove(index);
    });
    try {
      await Dio().download('http://$ip:$kServerPort/file/$index', savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) setState(() => _progress[index] = received / total);
      });
      setState(() {
        _progress[index] = 1.0;
        _savedPaths[index] = savePath;
      });
    } catch (e) {
      setState(() {
        _progress.remove(index);
        _statusMessage = 'Download failed: $e';
      });
    }
  }

  Future<void> _downloadAll() async {
    for (int i = 0; i < _fileList.length; i++) {
      await _downloadFile(i);
    }
  }

  String _formatSize(dynamic bytes) {
    final b = (bytes is int) ? bytes : int.tryParse('$bytes') ?? 0;
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Sender\'s IP',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16),
                      decoration: InputDecoration(
                        hintText: '192.168.1.x',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: const Color(0xFF0F0F1A),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isConnecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isConnecting
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Connect'),
                  ),
                ]),
                if (_statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(_statusMessage,
                      style: TextStyle(
                          fontSize: 12,
                          color: _isConnected
                              ? const Color(0xFF00E676)
                              : _statusMessage.contains('Could not')
                                  ? Colors.redAccent
                                  : Colors.white54)),
                ],
              ],
            ),
          ),

          if (_fileList.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(children: [
              Text('${_fileList.length} File(s) Available',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton.icon(
                onPressed: _downloadAll,
                icon: const Icon(Icons.download_for_offline_rounded, size: 16),
                label: const Text('Download All'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF6C63FF)),
              ),
            ]),
            const SizedBox(height: 8),
            ..._fileList.asMap().entries.map((entry) {
              final i = entry.key;
              final file = entry.value;
              final prog = _progress[i];
              final saved = _savedPaths[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C2E), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF6C63FF), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(file['name'] ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        Text(_formatSize(file['size']),
                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ]),
                    ),
                    if (saved != null)
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF00E676), size: 22),
                        onPressed: () => open_filex.OpenFilex.open(saved),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF6C63FF), size: 22),
                        onPressed: prog != null ? null : () => _downloadFile(i),
                      ),
                  ]),
                  if (prog != null && prog < 1.0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: prog,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 4),
                    Text('${(prog * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                  if (saved != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('✅ Downloaded',
                          style: TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                    ),
                ]),
              );
            }),
          ],

          const SizedBox(height: 16),
          _InfoBox(
            icon: Icons.wifi_rounded,
            text: 'Ask the sender to tap "Start Sharing" and share their IP with you. Enter it above and tap Connect.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable Widgets
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1C1C2E), borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5))),
      ]),
    );
  }
}
