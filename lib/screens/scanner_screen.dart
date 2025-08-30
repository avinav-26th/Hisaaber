import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/providers/bill_provider.dart';
import 'package:hisaaber_v1/screens/total_screen.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

// Add 'SingleTickerProviderStateMixin' for the animation controller
class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isProcessing = false;

  // New animation controller for the scan line
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();

    // Setup the animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _cameraController.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  void _onTakePicture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();

      if (!mounted) return;

      // Call the cropper with simplified UI settings
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Your Bill',
              toolbarColor: AppColors.primaryGreen, // Use our app's color
              toolbarWidgetColor: Colors.black, // Use our app's text color
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Crop Your Bill',
          ),
        ],
      );

      setState(() {
        if (croppedFile != null) {
          _capturedImage = XFile(croppedFile.path);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _onRetakePicture() {
    setState(() => _capturedImage = null);
  }

  void _onProceed() async {
    if (_capturedImage == null) return;

    setState(() => _isProcessing = true);

    final billProvider = context.read<BillProvider>();
    await billProvider.processImageAndParse(_capturedImage!.path);

    if (mounted) {
      // We 'await' the result of Navigator.push. The code will pause here
      // until the user presses the back button on the TotalScreen.
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TotalScreen()),
      );

      // When the user comes back, we reset the state to the live camera preview.
      setState(() {
        _isProcessing = false;
        _capturedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                if (_capturedImage == null)
                  Positioned.fill(child: CameraPreview(_cameraController))
                else
                  Positioned.fill(
                    child: Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.contain,
                    ),
                  ),

                if (_isProcessing) ...[
                  Container(color: Colors.black.withAlpha((255 * 0.5).round())),
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: Align(
                          alignment: Alignment(0, _scanAnimation.value),
                          child: Container(
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red,
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ],

                if (!_isProcessing)
                  Positioned(
                    bottom: 50,
                    left: 24,
                    right: 24,
                    child: _buildButtonControls(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonControls() {
    if (_capturedImage == null) {
      return FloatingActionButton(
        onPressed: _onTakePicture,
        child: const Icon(Icons.camera_alt),
      );
    } else {
      // The new circular buttons
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag:
                'retakeBtn', // Hero tag is needed when there are multiple FloatingActionButtons
            onPressed: _onRetakePicture,
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.replay),
          ),
          FloatingActionButton(
            heroTag: 'proceedBtn',
            onPressed: _onProceed,
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.check),
          ),
        ],
      );
    }
  }
}
