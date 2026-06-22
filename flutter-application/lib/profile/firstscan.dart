import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gardproject/profile/custom_gallery.dart';
import 'package:gardproject/profile/scanning.dart';

class ScanPlantScreen extends StatefulWidget {
  const ScanPlantScreen({super.key});

  @override
  State<ScanPlantScreen> createState() => _ScanPlantScreenState();
}

class _ScanPlantScreenState extends State<ScanPlantScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  String selectedGalleryImage = "";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.high);
    await controller!.initialize();
    setState(() {});
  }

  Future<void> openCustomGallery() async {
    final selectedImage = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomGalleryScreen(),
      ),
    );

    if (selectedImage != null) {
      setState(() {
        selectedGalleryImage = selectedImage;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Stack(
        children: [
          selectedGalleryImage.isNotEmpty
              ? Positioned.fill(
                  child: Image.asset(
                    selectedGalleryImage,
                    fit: BoxFit.cover,
                  ),
                )
              : CameraPreview(controller!),

          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    child: ScanCorner(
                      isTop: true,
                      isLeft: true,
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: ScanCorner(
                      isTop: true,
                      isLeft: false,
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: ScanCorner(
                      isTop: false,
                      isLeft: true,
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: ScanCorner(
                      isTop: false,
                      isLeft: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

         
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
  try {
    if (selectedGalleryImage.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanningScreen(
            imagePath: selectedGalleryImage,
            source: "gallery",
          ),
        ),
      );
      return;
    }

    final XFile file = await controller!.takePicture();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanningScreen(
          imagePath: file.path,
          source: "camera",
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to capture image: $e"),
      ),
    );
  }
},
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),

       
          Positioned(
            bottom: 90,
            left: 30,
            child: GestureDetector(
              onTap: openCustomGallery,
              child: CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(
                  selectedGalleryImage.isNotEmpty
                      ? selectedGalleryImage
                      : "",
                ),
              ),
            ),
          ),

         
          Positioned(
            bottom: 90,
            right: 30,
            child: Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flashlight_on,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const ScanCorner({
    super.key,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(25) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(25) : Radius.zero,
          bottomLeft:
              !isTop && isLeft ? const Radius.circular(25) : Radius.zero,
          bottomRight:
              !isTop && !isLeft ? const Radius.circular(25) : Radius.zero,
        ),
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: 7)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: 7)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 7)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 7)
              : BorderSide.none,
        ),
      ),
    );
  }
}