import 'dart:convert';
import 'dart:developer' as debug;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as google;
import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({super.key});

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  final String apiUrl =
      "https://us-central1-aiplatform.googleapis.com/v1/projects/speedy-elf-440420-s7/locations/us-central1/publishers/google/models/gemini-1.5-flash-002:generateContent"; // Update with your API
  List<Map<String, dynamic>> milestones = [];
  bool isLoading = true; // Start loading as true
  File? _uploadedImage; // Store uploaded image
  String? _enhancedImageUrl; // Future image URL after enhancement

  @override
  void initState() {
    super.initState();
    _loadData(); // Fetch data on initialization
  }

  Future<List<String>> _fetchInterestsFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          var interests = data?['interests'];

          if (interests is List) {
            return interests.map((interest) => interest.toString()).toList();
          } else {
            debug.log(
                "No interests found for the user or interests is not a list.");
            return [];
          }
        } else {
          debug.log("User document does not exist.");
          return [];
        }
      } else {
        debug.log("User is not logged in!");
        return [];
      }
    } catch (e) {
      debug.log('Error fetching interests: $e');
      return [];
    }
  }

  Future<void> _loadData() async {
    List<String> interests = await _fetchInterestsFromFirestore();
    if (interests.isNotEmpty) {
      debug.log(interests.toString());
      // await fetchMilestones(interests);
      await generateInterest(interests: interests);
    } else {
      // No interests found, load default milestones
      loadDefaultMilestones();
    }
    setState(() {
      // _enhancedImageUrl = 'assets/images/business-success.jpg';
      _enhancedImageUrl = 'assets/images/futureYou.jpeg';
    });
  }

  Future<void> fetchMilestones(List<String> interests) async {
    final requestBody = {'interest': interests};
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Bearer 44dc48c05898c2fbe506225edab290d3c8febe91', // Use your API key
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

        setState(() {
          milestones = data.map((item) {
            return {
              'title': item['title'] ?? 'Untitled Milestone',
              'description': item['description'] ?? '',
            } as Map<String, String>;
          }).toList();
          isLoading = false;
          debug.log(milestones
              .toString()); // Set loading to false after data is fetched
        });
      } else {
        debug.log(response.body); // Set loading to true after data is fetched)
        throw Exception("Failed to load milestones");
      }
    } catch (e) {
      debug.log("Error fetching milestones: $e");
      loadDefaultMilestones(); // Load default milestones on error
    }
  }

  void loadDefaultMilestones() {
    // Define your default milestones
    setState(() {
      milestones = [
        {
          'title': 'Create a Business Plan',
          'description': 'Outline your business goals and strategies.',
        },
        {
          'title': 'Register Your Business',
          'description': 'Officially register your business and choose a name.',
        },
        {
          'title': 'Launch Your Website',
          'description': 'Create an online presence for your business.',
        },
        {
          'title': 'Start Marketing',
          'description': 'Promote your business through social media and ads.',
        },
      ];
      isLoading =
          false; // Set loading to false after loading default milestones
    });
  }

  Future<void> generateInterest({List<String> interests = const []}) async {
    final apiKey = 'AIzaSyB4ZwpnhVUGH6YrEL4W24oUCazOCI3NiYk';
    final model = google.GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    try {
      final prompt =
          'Given an array of interests [${interests.join(',')}], identify the top career pathways that align closely with each interest. For each pathway, provide a brief overview of the career, typical roles or job titles, required skills, and potential educational or training steps needed to succeed. Prioritize pathways that reflect personal growth, societal impact, and strong future demand. Ensure each recommendation is inspiring and relevant to someone exploring their options for long-term success and return it in json format of list title and description.';
      debug.log("Here => $prompt");
      final response = await model.generateContent([
        google.Content.multi([google.TextPart(prompt)])
      ]);

      if (response.text != null) {
        // debug.log(response.text ?? '');
        var newText =
            response.text!.replaceAll('```json', '').replaceAll('```', '');
        // debug.log("Here => ${jsonDecode(newText)}");
        // debug.log("Here => ${JsonEncoder.withIndent('  ').convert(newText)}");
        // debug.log("Here => $newText");
        // var formattedText = formatToJson(newText);
        List<dynamic> data = jsonDecode(newText) as List<dynamic>;
        setState(() {
          milestones = data.map((item) {
            return {
              'title': item['title'] ?? 'Untitled Milestone',
              'description': item['description'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        debug.log("No text response from the model.");
      }
      debug.log("Here => $milestones");
    } catch (e) {
      debug.log(e.toString());
    }
  }

  String formatToJson(String rawText) {
    // Split the input text by lines

    List<String> lines = rawText.split('\n');

    // Prepare to store the formatted JSON
    List<Map<String, String>> formattedList = [];
    String? currentTitle;
    String? currentDescription;

    // Process each line and build the formatted JSON
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        continue;
      }

      // If the line contains a title (assuming the title is a category name like "Software Engineering")
      if (currentTitle == null) {
        currentTitle = line;
      } else {
        currentDescription = line;

        // Add to the list when both title and description are available
        formattedList.add({
          'title': currentTitle,
          'description': currentDescription,
        });

        // Reset for the next title
        currentTitle = null;
        currentDescription = null;
      }
    }

    // Return the formatted JSON as a string
    return jsonEncode(formattedList);
  }

  // Future<void> generateInterest({String imageLocation = ''}) async {
  //   final apiKey = 'AIzaSyB4ZwpnhVUGH6YrEL4W24oUCazOCI3NiYk';
  //   final model = google.GenerativeModel(
  //     model: 'gemini-1.5-flash',
  //     apiKey: apiKey,
  //   );

  //   try {
  //     final imagePath = imageLocation;
  //     final prompt =
  //         "Using the provided base image, enhance the portrait to depict a successful future version of this individual. Show an inspiring transformation, focusing on professional confidence, wisdom, and success. Subtly add elements like a polished, professional appearance, a confident smile, and vibrant energy that suggest their journey toward achievement. Retain the person's core features, but subtly enhance them to reflect growth, determination, and potential fulfillment of their career aspirations. Make the upgraded image realistic, with no extreme alterations, just natural progress to the best version of themselves.";

  //     // Check if the image file exists
  //     final file = File(imagePath);
  //     if (!await file.exists()) {
  //       throw FileSystemException("File not found", imagePath);
  //     }

  //     // Convert the image file to a DataPart with error handling
  //     final image = await fileToPart('image/jpeg', imagePath);

  //     // Generate content from model with both prompt and image
  //     final response = await model.generateContent([
  //       google.Content.multi([google.TextPart(prompt), image])
  //     ]);

  //     if (response.text != null) {
  //       debug.log('Here: ==> ${response.usageMetadata?.promptTokenCount}');
  //       debug.log(response.text ?? '');
  //     } else {
  //       debug.log("No text response from the model.");
  //     }
  //   } catch (e) {
  //     debug.log(e.toString());
  //     // if (e is FileSystemException) {
  //     //   print("Error: ${e.message} - ${e.path}");
  //     // } else if (e is GenerativeModelException) {
  //     //   print("Generative Model Error: ${e.message}");
  //     // } else {
  //     //   print("An unexpected error occurred: $e");
  //     // }
  //   }
  // }

  Future<google.DataPart> fileToPart(String mimeType, String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return google.DataPart(mimeType, bytes);
    } catch (e) {
      debug.log("Failed to read file: $e");
      rethrow; // Re-throws to be caught by outer try-catch
    }
  }

  Future<void> generateImage({String imageLocation = ''}) async {
    // final apiKey = 'AIzaSyB4ZwpnhVUGH6YrEL4W24oUCazOCI3NiYk';
    // final apiKey = '44dc48c05898c2fbe506225edab290d3c8febe91';
    final apiKey = '103976450464665827362';
    const projectId = 'speedy-elf-440420-s7';
    const location = 'us-central1';
    const promptText = 'Apply a vintage filter to this image';

    final endpoint =
        'https://$location-aiplatform.googleapis.com/v1/projects/$projectId/locations/$location/publishers/google/models/imagen-3.0-edit-001:predict';

    // Read and encode image in Base64
    final bytes = await File(imageLocation).readAsBytes();
    final base64Image = base64Encode(bytes);

    // Prepare the request payload with both the prompt and image
    final payload = {
      "instances": [
        {
          "prompt": promptText,
          "image": base64Image,
        }
      ],
      "parameters": {
        "sampleCount": 1,
        "aspectRatio": "1:1",
        "safetyFilterLevel": "block_some",
        "personGeneration": "allow_adult",
      }
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiKey,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final predictions = responseData['predictions'] as List?;
        if (predictions != null && predictions.isNotEmpty) {
          final editedImageData = predictions[0]['structValue']['fields']
              ['bytesBase64Encoded']['stringValue'] as String;
          final decodedBytes = base64Decode(editedImageData);

          final outputFilename = 'edited_output.png';
          var newImage = await File(outputFilename).writeAsBytes(decodedBytes);
          debug.log('Edited image saved as $outputFilename');
          setState(() {
            _enhancedImageUrl = newImage.path;
          });
          // return outputFilename;
        } else {
          debug.log('No edited image generated.');
        }
      } else {
        debug.log(
            'Failed to edit image: ${response.statusCode} ${response.reasonPhrase}');
        debug.log(response.body);
      }
    } catch (e) {
      debug.log('An error occurred: $e');
    }
  }

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _uploadedImage = File(pickedFile.path);
  //       _enhancedImageUrl = null;
  //     });
  //   }
  //   await generateImage(imageLocation: _uploadedImage!.path);
  // }

  // void _enhanceImage() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     try {} catch (e) {}
  //     setState(() {
  //       _enhancedImageUrl =
  //           "https://ai.google.dev/gemini-api/docs/vision?lang=rest"; // Placeholder URL
  //     });
  //   });
  // }

  Widget buildMilestoneItem(Map<String, dynamic> milestone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Theme.of(context).colorScheme.secondaryContainer)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.check, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              milestone['title']!.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              milestone['description']!.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Path to Success"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.secondary),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ElevatedButton(
                //   onPressed: _pickImage,
                //   child: const Text("Upload Your Image"),
                // ),
                if (_uploadedImage != null || _enhancedImageUrl != null)
                  FutureSelfView(
                    originalImageUrl: _uploadedImage?.path,
                    enhancedImageUrl: _enhancedImageUrl,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Here’s your journey to becoming your future self!",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                // SizedBox(
                //   height: 400,
                //   width: double.infinity,
                //   child:
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: milestones.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildMilestoneItem(milestones[index]),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Stay motivated and complete each milestone to reach your goals!",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}

class FutureSelfView extends StatelessWidget {
  final String? originalImageUrl;
  final String? enhancedImageUrl;

  const FutureSelfView({
    this.originalImageUrl,
    this.enhancedImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (originalImageUrl != null) const Text("Current You"),
        if (originalImageUrl != null)
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.file(
              width: double.infinity,
              File(originalImageUrl ?? ''),
            ),
          )
        else
          SizedBox(),
        if (originalImageUrl != null) const SizedBox(height: 20),
        const Text("Future You"),
        if (enhancedImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(
                  //     color: Theme.of(context).colorScheme.secondaryContainer),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: Offset(5, 5),
                    )
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  enhancedImageUrl ?? 'assets/images/jlk_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              // Image.network(
              // enhancedImageUrl!,
              //   loadingBuilder: (context, child, loadingProgress) => Center(
              //     child: const CircularProgressIndicator(),
              //   ),
              // ),
            ),
          )
        else
          const CircularProgressIndicator(),
      ],
    );
  }
}

// FormData formData = FormData.fromMap({
//   'file': await MultipartFile.fromFile(pickedFile.path,
//       filename: pickedFile.name),
// });
// // final requestBody = {
// //   'filepath': pickedFile.path,
// //   'filename': pickedFile.name,
// // };
// final requestBody = {
//   'file': await MultipartFile.fromFile(pickedFile.path,
//       filename: pickedFile.name),
// };

// try {
//   final response = await http.post(
//       Uri.parse(
//           'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyB4ZwpnhVUGH6YrEL4W24oUCazOCI3NiYk'),
//       // Uri.parse(
//       //     'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyB4ZwpnhVUGH6YrEL4W24oUCazOCI3NiYk'),
// headers: {
//   'Authorization':
//       'Bearer 44dc48c05898c2fbe506225edab290d3c8febe91', // Use your API key
//   'Content-Type': 'application/json',
// },
//       body: requestBody);
//   if (response.statusCode == 200) {
//     debug.log('Here: ${response.body.toString()}');
//   } else {
//     debug.log('Here1: ${response.body.toString()}');
//   }
// } catch (e) {
//   debug.log(e.toString());
// }
// // Simulate image enhancement process
// // _enhanceImage();
