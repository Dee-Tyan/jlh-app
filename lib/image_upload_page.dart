// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  String? imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final _ = await picker.pickImage(source: ImageSource.gallery);
    await Navigator.pushReplacementNamed(context, '/main');
  }

  // Future<void> pickImage() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //     allowMultiple: false,
  //   );

  //   if (result != null && result.files.isNotEmpty) {
  //     await Navigator.pushReplacementNamed(context, '/main');
  //     // final file = result.files.first;
  //     // final reader = html.FileReader();
  //     // reader.readAsDataUrl(file.bytes!.buffer.asUint8List());
  //     // reader.onLoadEnd.listen((e) {
  //     //   setState(() {
  //     //     imageUrl = reader.result as String;
  //     //   });
  //     // });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            if (imageUrl != null) Image.network(imageUrl!),
          ],
        ),
      ),
    );
  }
}
