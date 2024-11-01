import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'hero_animating_recommendation_card.dart'; // Add this import
import 'widgets.dart';


class RecommendationPlaceholderTile extends StatelessWidget {
  const RecommendationPlaceholderTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.recommend),
      title: const Text('Recommendation Placeholder'),
      subtitle: const Text('More details about this recommendation...'),
      onTap: () {
        // You can add an action here if needed
      },
    );
  }
}

/// Page shown when a card in the recommendations tab is tapped.
///
/// On Android, this page sits at the top of your app. On iOS, this page is on
/// top of the recommendations tab's content but is below the tab bar itself.
class RecommendationDetailTab extends StatelessWidget {
  const RecommendationDetailTab({
    required this.id,
    required this.recommendation,
    required this.color,
    super.key,
  });

  final int id;
  final String recommendation;
  final Color color;

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: id,
            child: HeroAnimatingRecommendationCard(
              recommendation: recommendation,
              color: color,
              heroAnimation: const AlwaysStoppedAnimation(1), onPressed: () {  },
            ),
            flightShuttleBuilder: (context, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return HeroAnimatingRecommendationCard(
                recommendation: recommendation,
                color: color,
                heroAnimation: animation, onPressed: () {  },
              );
            },
          ),
          const Divider(
            height: 0,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => switch (index) {
                0 => const Padding(
                    padding: EdgeInsets.only(left: 15, top: 16, bottom: 8),
                    child: Text(
                      'Related recommendations:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                _ => const RecommendationPlaceholderTile(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recommendation)),
      body: _buildBody(),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(recommendation),
        previousPageTitle: 'Recommendations',
      ),
      child: _buildBody(),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}
