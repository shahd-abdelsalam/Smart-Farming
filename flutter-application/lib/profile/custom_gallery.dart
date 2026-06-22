import 'package:flutter/material.dart';

class CustomGalleryScreen extends StatelessWidget {
  const CustomGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> folders = [
      {
        "folderName": "Bacterial Spot",
        "images": [
          "images/photo_2026-05-08_15-27-27.jpg",
        ],
      },
      {
        "folderName": "Healthy",
        "images": [
          "images/photo_2026-05-08_15-27-29.jpg",
        ],
      },
      {
        "folderName": "Early Blight",
        "images": [
          "images/photo_2026-05-08_15-27-31.jpg",
        ],
      },
      {
        "folderName": "Late Blight",
        "images": [
          "images/photo_2026-05-08_15-27-33.jpg",
        ],
      },
      {
        "folderName": "Yellow Leaf ",
        "images": [
          "images/photo_2026-05-08_15-27-35.jpg",
        ],
      },
      {
        "folderName": "Bacterial Spot",
        "images": [
          "images/photo_2026-05-08_15-27-36.jpg",
        ],
      },
      {
        "folderName": "Septoria Leaf Spot",
        "images": [
          "images/photo_2026-05-08_15-27-38.jpg",
        ],
      },
      {
        "folderName": "Healthy",
        "images": [
          "images/photo_2026-05-08_15-27-39.jpg",
        ],
      },
      {
        "folderName": "Early Blight",
        "images": [
          "images/photo_2026-05-08_15-27-41.jpg",
        ],
      },
      {
        "folderName": "Leaf Mold",
        "images": [
          "images/photo_2026-05-08_15-27-42.jpg",
        ],
      },
      {
        "folderName": "Spider mites",
        "images": [
          "images/photo_2026-05-08_15-27-44.jpg",
        ],
      },
      {
        "folderName": "Target Spot",
        "images": [
          "images/photo_2026-05-08_15-27-45.jpg",
        ],
      },
      {
        "folderName": "Late Blight",
        "images": [
          "images/photo_2026-05-08_15-27-46.jpg",
        ],
      },
      {
        "folderName": "Mosaic Virus",
        "images": [
          "images/photo_2026-05-08_15-27-48.jpg",
        ],
      },
      {
        "folderName": "Septoria Leaf Spot",
        "images": [
          "images/photo_2026-05-08_15-27-49.jpg",
        ],
      },
      {
        "folderName": "Yellow Leaf",
        "images": [
          "images/photo_2026-05-08_15-27-50.jpg",
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Folders"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: folders.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final folder = folders[index];

            return GestureDetector(
            onTap: () async {
  final selectedImage = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (_) => FolderImagesScreen(
        folderName: folder["folderName"],
        images: List<String>.from(folder["images"]),
      ),
    ),
  );

  if (selectedImage != null && context.mounted) {
    Navigator.pop(context, selectedImage);
  }
},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder,
                      size: 70,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      folder["folderName"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FolderImagesScreen extends StatelessWidget {
  final String folderName;
  final List<String> images;

  const FolderImagesScreen({
    super.key,
    required this.folderName,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final imagePath = images[index];

            return GestureDetector(
              onTap: () {
                Navigator.pop(context, imagePath);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}