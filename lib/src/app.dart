import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class OverlayService {
  static Future<void> showOverlay() async {
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.requestPermission();
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      height: 100,
      width: 100,
      alignment: OverlayAlignment.centerRight,
      visibility: NotificationVisibility.visibilityPublic,
      flag: OverlayFlag.defaultFlag,
      overlayTitle: 'Floating Controls',
      enableDrag: true,
      startPosition: const OverlayPosition(0, 0),
      overlayContent: "FloatingControlsOverlay",
      positionGravity: PositionGravity.auto,
    );
  }

  static Future<void> hideOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }
}

class FloatingControlsOverlay extends StatefulWidget {
  const FloatingControlsOverlay({super.key});

  @override
  _FloatingControlsOverlayState createState() =>
      _FloatingControlsOverlayState();
}

class _FloatingControlsOverlayState extends State<FloatingControlsOverlay> {
  bool _isExpanded = false;
  final VolumeController _volumeController = VolumeController();
  StreamSubscription? _overlaySubscription;

  @override
  void initState() {
    super.initState();
    _overlaySubscription = FlutterOverlayWindow.overlayListener.listen((event) {
      log("Overlay event received: $event");
      if (event == "close") {
        // Handle close event
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _overlaySubscription?.cancel();
    super.dispose();
  }

  void _volumeUp() async {
    try {
      // Get current volume
      final currentVolume = await _volumeController.getVolume();

      // Increase volume by 0.1 (10%)
      _volumeController.setVolume((currentVolume + 0.1).clamp(0.0, 1.0));
    } catch (e) {
      print('Volume up error: $e');
    }
  }

  void _volumeDown() async {
    try {
      // Get current volume
      final currentVolume = await _volumeController.getVolume();

      // Decrease volume by 0.1 (10%)
      _volumeController.setVolume((currentVolume - 0.1).clamp(0.0, 1.0));
    } catch (e) {
      print('Volume down error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350), // Slightly longer duration
        curve: Curves.easeInOut, // Smoother animation curve
        width: 50,
        height: _isExpanded ? 250 : 50,
        decoration: BoxDecoration(
          color: Colors
              .black54, // Slightly darker background for better visibility
          borderRadius: BorderRadius.circular(25),
        ),
        child: _isExpanded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(Icons.volume_up, _volumeUp),
                  _buildIconButton(Icons.volume_down, _volumeDown),
                  _buildIconButton(Icons.close_sharp, () {
                    OverlayService.hideOverlay();
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }),
                  _buildIconButton(Icons.expand_more, toggle),
                ],
              )
            : Center(
                child: _buildIconButton(Icons.expand_less, toggle),
              ),
      ),
    );
  }

// Helper method to reduce repetitive code
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4.0), // Slightly larger padding
      child: IconButton(
        icon:
            Icon(icon, color: Colors.white, size: 24), // Slightly larger icons
        onPressed: onPressed,
      ),
    );
  }

  Future<void> toggle() async {
    await FlutterOverlayWindow.resizeOverlay(
        50, // Consistent width
        _isExpanded ? 50 : 250, // Dynamic height
        !_isExpanded ? false : true // Smooth resizing
        );
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}

// Main App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black87,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Volume Button Assistant'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Manage your assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text('Show Assistant'),
                onPressed: () => OverlayService.showOverlay(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility_off),
                label: const Text('Hide Assistant'),
                onPressed: () {
                  FlutterOverlayWindow.shareData("close");
                  OverlayService.hideOverlay();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
