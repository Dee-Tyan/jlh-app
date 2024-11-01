import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';

// class ImageUploadService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   Future<String?> uploadUserImage(String userId) async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final Reference ref = _storage.ref().child('user_images/$userId');
//       await ref.putFile(File(pickedFile.path));
//       return await ref.getDownloadURL();
//     }
//     return null;
//   }
// }

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadUserImage(String userId) async {
    // Pick an image
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return null;

    // Create a reference to the user's folder in Firebase Storage
    final ref = _storage.ref().child("users/$userId/original_image.jpg");

    // Upload the image to Firebase Storage
    final uploadTask = await ref.putFile(File(pickedImage.path));
    return await ref.getDownloadURL(); // Return the URL for display or further processing
  }
}



class ImagePickerExample extends StatefulWidget {
  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}