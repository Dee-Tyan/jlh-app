import 'package:flutter/material.dart';

class HeroAnimatingRecommendationCard extends StatelessWidget {
  final String recommendation;
  final MaterialColor color;
  final Animation<double> heroAnimation;
  final VoidCallback onPressed;

  const HeroAnimatingRecommendationCard({
    Key? key,
    required this.recommendation,
    required this.color,
    required this.heroAnimation,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: color,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: recommendation,
                child: CircleAvatar(
                  backgroundColor: color.shade200,
                  child: Text(recommendation[0]), // Display the first letter as an example
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  recommendation,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
