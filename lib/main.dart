import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jlk_app/image_upload_page.dart';

import 'firebase_options.dart';
import 'interest_selection_screen.dart'; //second screen after linked screen - if user doesn't have an account
import 'login_screen.dart'; //second screen
import 'news_tab.dart';
import 'profile_tab.dart';
import 'recommendations_tab.dart';
import 'settings_tab.dart';
import 'signup_screen.dart'; //linked screen
import 'songs_tab.dart';
import 'splash_screen.dart'; //first screen
import 'welcome_screen.dart'; //third screen before accessing main app
import 'widgets.dart';

const Color babyPowder = Color(0xFFFFF7F7); // Baby Powder
const Color pinkLavender = Color(0xFFFBCAEF); // Pink Lavender
const Color darkPink = Color(0xFF8A1C7C); // Dark Pink
const Color blackOlive = Color(0xFF343633); // Black Olive
const Color licorice = Color(0xFF0B0014); // Licorice

// void main() =>  runApp(const MyAdaptingApp());

// WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
// runApp(const MyAdaptingApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(MyAdaptingApp());
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Just Like Her App',
//       theme: ThemeData(primarySwatch: Colors.pink),
//       home: RecommendationsTab(), // Set RecommendationsTab as the default home
//     );
//   }
// }

class MyAdaptingApp extends StatelessWidget {
  const MyAdaptingApp({super.key});

  @override
  Widget build(context) {
    // Either Material or Cupertino widgets work in either Material or Cupertino
    // Apps.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Just Like Her App',
      // theme: ThemeData(
      //   // Use the green theme for Material widgets.
      //   primarySwatch: Colors.green,
      // ),
      // darkTheme: ThemeData.dark(),
      theme: ThemeData(
        primaryColor: darkPink,
        scaffoldBackgroundColor: babyPowder,
        appBarTheme: AppBarTheme(
          backgroundColor: darkPink,
          foregroundColor: babyPowder,
        ),
        colorScheme: ColorScheme.light(
            primary: darkPink,
            secondary: pinkLavender,
            surface: babyPowder,
            secondaryContainer: darkPink
            // surface: blackOlive,
            ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: blackOlive),
          bodyMedium: TextStyle(color: licorice),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: licorice,
        scaffoldBackgroundColor: blackOlive,
        appBarTheme: AppBarTheme(
          backgroundColor: licorice,
          foregroundColor: babyPowder,
        ),
        colorScheme: ColorScheme.dark(
            primary: licorice,
            secondary: darkPink,
            background: blackOlive,
            surface: pinkLavender,
            secondaryContainer: darkPink),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: babyPowder),
          bodyMedium: TextStyle(color: pinkLavender),
        ),
      ),
      initialRoute: '/', // Starting with SplashScreen
      routes: {
        '/': (context) => SplashScreen(), // Starting with Splash Screen
        '/login': (context) => LoginScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignupScreen(),
        '/interestSelection': (context) => InterestSelectionScreen(),
        '/home': (context) => const RecommendationsTab(),
        '/main': (context) => const RecommendationsTab(),
        '/imageUpload': (context) => ImageUploadPage(),
        // const PlatformAdaptingHomePage(), // Main app content
      },
      // builder: (context, child) {
      //   return CupertinoTheme(
      //     // Instead of letting Cupertino widgets auto-adapt to the Material
      //     // theme (which is green), this app will use a different theme
      //     // for Cupertino (which is blue by default).
      //     data: const CupertinoThemeData(),
      //     child: Material(child: child),
      //   );
      // },
      builder: (context, child) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            primaryColor: darkPink,
            barBackgroundColor: licorice,
            scaffoldBackgroundColor: babyPowder,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(color: blackOlive),
            ),
          ),
          child: Material(child: child),
        );
      },
      // home: const PlatformAdaptingHomePage(),
    );
  }
}

// Shows a different type of scaffold depending on the platform.
//
// This file has the most amount of non-sharable code since it behaves the most
// differently between the platforms.
//
// These differences are also subjective and have more than one 'right' answer
// depending on the app and content.
class PlatformAdaptingHomePage extends StatefulWidget {
  const PlatformAdaptingHomePage({super.key});

  @override
  State<PlatformAdaptingHomePage> createState() =>
      _PlatformAdaptingHomePageState();
}

class _PlatformAdaptingHomePageState extends State<PlatformAdaptingHomePage> {
  // This app keeps a global key for the songs tab because it owns a bunch of
  // data. Since changing platform re-parents those tabs into different
  // scaffolds, keeping a global key to it lets this app keep that tab's data as
  // the platform toggles.
  //
  // This isn't needed for apps that doesn't toggle platforms while running.
  final songsTabKey = GlobalKey();

  // In Material, this app uses the hamburger menu paradigm and flatly lists
  // all 4 possible tabs. This drawer is injected into the songs tab which is
  // actually building the scaffold around the drawer.
  Widget _buildAndroidHomePage(BuildContext context) {
    return SongsTab(
      key: songsTabKey,
      androidDrawer: _AndroidDrawer(),
    );
  }

  // On iOS, the app uses a bottom tab paradigm. Here, each tab view sits inside
  // a tab in the tab scaffold. The tab scaffold also positions the tab bar
  // in a row at the bottom.
  //
  // An important thing to note is that while a Material Drawer can display a
  // large number of items, a tab bar cannot. To illustrate one way of adjusting
  // for this, the app folds its fourth tab (the settings page) into the
  // third tab. This is a common pattern on iOS.
  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            label: SongsTab.title,
            icon: SongsTab.iosIcon,
          ),
          BottomNavigationBarItem(
            label: NewsTab.title,
            icon: NewsTab.iosIcon,
          ),
          BottomNavigationBarItem(
            label: ProfileTab.title,
            icon: ProfileTab.iosIcon,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        assert(index <= 2 && index >= 0, 'Unexpected tab index: $index');
        return switch (index) {
          0 => CupertinoTabView(
              defaultTitle: 'Timeline',
              builder: (context) => RecommendationsTab(key: songsTabKey),
            ),
          1 => CupertinoTabView(
              defaultTitle: NewsTab.title,
              builder: (context) => const NewsTab(),
            ),
          2 => CupertinoTabView(
              defaultTitle: ProfileTab.title,
              builder: (context) => const ProfileTab(),
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }
}

class _AndroidDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.account_circle,
                color: Colors.green.shade800,
                size: 96,
              ),
            ),
          ),
          ListTile(
            leading: SongsTab.androidIcon,
            title: const Text(SongsTab.title),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: NewsTab.androidIcon,
            title: const Text(NewsTab.title),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(context,
                  MaterialPageRoute(builder: (context) => const NewsTab()));
            },
          ),
          ListTile(
            leading: ProfileTab.androidIcon,
            title: const Text(ProfileTab.title),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(context,
                  MaterialPageRoute(builder: (context) => const ProfileTab()));
            },
          ),
          // Long drawer contents are often segmented.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          ListTile(
            leading: SettingsTab.androidIcon,
            title: const Text(SettingsTab.title),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(context,
                  MaterialPageRoute(builder: (context) => const SettingsTab()));
            },
          ),
        ],
      ),
    );
  }
}
