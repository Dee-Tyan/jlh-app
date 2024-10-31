import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock function to simulate an AI API call that returns personalized data
Future<Map<String, dynamic>> fetchAIRecommendations(
    List<String> userInterests) async {
  // Replace this with the actual call to your AI service endpoint
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

  return {
    'userName': 'Alex', // Replace with dynamic user name from AI response
    'careerTimeline': [
      'Learn basics of programming',
      'Complete a project in Software Engineering',
      'Apply for internships',
      'Get certified in advanced topics',
      'Land your first job as a Software Engineer'
    ]
  };
}

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  _RecommendationsTabState createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  final List<String> userInterests = [
    'Software Engineering',
    'Web Development'
  ];
  List<DocumentSnapshot> recommendedCourses = [];
  Map<String, dynamic> personalizedData = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Fetch recommended courses and personalized AI data
    recommendedCourses = await getCourseRecommendations(userInterests);
    personalizedData = await fetchAIRecommendations(userInterests);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (personalizedData.isNotEmpty) ...[
            Text(
              'Hello, ${personalizedData['userName']}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Here’s your career path to becoming a successful ${userInterests[0]}:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...((personalizedData['careerTimeline'] as List?)
                    ?.map<Widget>((step) {
                  return ListTile(
                    leading:
                        Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text(step
                        .toString()), // Ensuring step is converted to String
                  );
                }).toList() ??
                []), // If null, fallback to an empty list
            const Divider(),
            const SizedBox(height: 16),
          ],
          Text(
            'Recommended Courses:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ...recommendedCourses.map((course) {
            var courseData = course.data() as Map<String, dynamic>;
            return ListTile(
              title: Text((courseData['name'] ?? 'Course Name').toString()),
              subtitle: Text(
                  'Difficulty: ${(courseData['difficulty'] ?? 'Unknown').toString()}'),
              onTap: () {
                // Navigate to course detail if necessary
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Function to fetch recommended courses
Future<List<DocumentSnapshot>> getCourseRecommendations(
    List<String> userInterests) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('courses')
      .where('careerPaths', arrayContainsAny: userInterests)
      .get();

  final sortedCourses = querySnapshot.docs
    ..sort(
        (a, b) => (a['difficulty'] as int).compareTo(b['difficulty'] as int));
  return sortedCourses;
}
