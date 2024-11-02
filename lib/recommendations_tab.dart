import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // New import for image picking
import 'dart:io';

import 'utils.dart'; // Update this import based on the helper functions available
import 'widgets.dart';

class FutureSelfView extends StatelessWidget {
  final String originalImageUrl;
  final String? enhancedImageUrl;

  const FutureSelfView({
    required this.originalImageUrl,
    this.enhancedImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Current You"),
        Image.file(File(originalImageUrl)),
        const SizedBox(height: 20),
        const Text("Future You"),
        if (enhancedImageUrl != null)
          Image.network(enhancedImageUrl!)
        else
          const CircularProgressIndicator(),
      ],
    );
  }
}

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();
  File? _uploadedImage;
  String? _enhancedImageUrl;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _uploadedImage = File(pickedFile.path);
        _enhancedImageUrl = null;
      });
      _enhanceImage();
    }
  }

  void _enhanceImage() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _enhancedImageUrl = "https://example.com/enhanced_image.jpg";
      });
    });
  }

  Widget _buildMotivationSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Believe in your future self! Every small step brings you closer to who you want to become.",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAchievementsList() {
    List<String> achievements = [
      "Complete basic coding course",
      "Join STEM workshops",
      "Finish project portfolio",
      "Connect with a mentor",
      "Participate in a hackathon",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: achievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.pinkAccent, // Brand color
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    achievement,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Future Steps"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async => await _androidRefreshKey.currentState!.show(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Upload Your Image"),
          ),
          if (_uploadedImage != null)
            FutureSelfView(
              originalImageUrl: _uploadedImage!.path,
              enhancedImageUrl: _enhancedImageUrl,
            ),
          const SizedBox(height: 20),
          _buildMotivationSection(),
          const SizedBox(height: 20),
          const Text(
            "Steps to Achieve Your Goals:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              key: _androidRefreshKey,
              onRefresh: () => Future.delayed(const Duration(seconds: 2)),
              child: SingleChildScrollView(
                child: _buildAchievementsList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAndroid(context);
  }
}
