import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class VideoPlayerWidget extends StatefulWidget {
  final String imageUrl;

  VideoPlayerWidget({required this.imageUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? errorText;
  @override
  void initState() {
    super.initState();
    _loadImage();
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.imageUrl)
      ..initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
        });
      });
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final http.Response response = await http.get(Uri.parse(widget.imageUrl));
      final Uint8List bytes = response.bodyBytes;

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load image: $e');
    }
  }

  Future<void> _saveImageToDevice() async {
    try {
      final String appName = 'E112';
      Directory appDir;
      if (Platform.isAndroid) {
        final String picturesDirectory =
            '/storage/emulated/0/Pictures/$appName';
        await Directory(picturesDirectory).create(recursive: true);
        final String fileName = widget.imageUrl.split('/').last;
        final File imageFile = File('$picturesDirectory/$fileName');
        await imageFile.writeAsBytes(_imageBytes!);
        var location = picturesDirectory;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $location')),
        );
      } else {
        // Jika di platform lain, gunakan path aplikasi
        final directory = await getDownloadsDirectory();
        final String picturesDirectory = '${directory!.path}/Pictures/$appName';
        await Directory(picturesDirectory).create(recursive: true);
        final String fileName = widget.imageUrl.split('/').last;
        final File imageFile = File('$picturesDirectory/$fileName');
        await imageFile.writeAsBytes(_imageBytes!);
        var location = picturesDirectory;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $location')),
        );
      }
    } catch (e) {
      print('Failed to save image: $e');
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin plugin = DeviceInfoPlugin();
      AndroidDeviceInfo android = await plugin.androidInfo;
      if (android.version.sdkInt < 33) {
        if (await Permission.storage.request().isGranted) {
          setState(() {
            _saveImageToDevice();
          });
        } else if (await Permission.storage.request().isPermanentlyDenied) {
          await openAppSettings();
        } else if (await Permission.audio.request().isDenied) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied')),
            );
          });
        }
      } else {
        if (await Permission.photos.request().isGranted) {
          setState(() {
            _saveImageToDevice();
          });
        } else if (await Permission.photos.request().isPermanentlyDenied) {
          await openAppSettings();
        } else if (await Permission.photos.request().isDenied) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied')),
            );
          });
        }
      }
    } else {
      // Jika bukan Android, langsung lakukan penyimpanan gambar tanpa perlu izin
      _saveImageToDevice();
    }
  }

  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(2, 15, 35, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(2, 15, 35, 1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color.fromRGBO(135, 182, 255, 1),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Webm',
            style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.download),
                onPressed: _isLoading ? null : _requestPermission,
                color: Color.fromRGBO(135, 182, 255, 1)),
          ],
        ),
        body: (Platform.isAndroid)
            ? errorText != null
                ? buildErrorWidget()
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageBytes != null
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_controller),
                                if (!_isPlaying)
                                  GestureDetector(
                                    onTap: () {
                                      _controller.play();
                                      setState(() {
                                        _isPlaying = true;
                                      });
                                    },
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 72,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const Center(child: Text('Failed to load image'))
            : errorText != null
                ? buildErrorWidget()
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageBytes != null
                        ? Center(
                            child: Text(
                              'Linux not support webm yet, the alternatively download it',
                              style: TextStyle(
                                  color: Color.fromRGBO(135, 182, 255, 1)),
                            ),
                          )
                        : Center(
                            child: Text(
                              'Linux not support webm yet, the alternatively download it',
                              style: TextStyle(
                                  color: Color.fromRGBO(135, 182, 255, 1)),
                            ),
                          ));
  }

  Widget buildErrorWidget() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              errorText!,
              style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorText = null; // Hapus pesan kesalahan dan coba lagi
                });
                _loadImage(); // Panggil fetchData() kembali
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
