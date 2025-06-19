import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/technologies.dart';
import 'screens/sections.dart';
import 'models/technology.dart';
import 'services/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SettingsService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frontend Learning App',
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      //checkerboardRasterCacheImages: true,
      //checkerboardOffscreenLayers: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        // Performance optimizations
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _createRoute(const HomeScreen());
      case '/technologies':
        return _createRoute(const TechnologiesScreen());
      case '/sections':
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        final technology = args['technology'] as Technology;
        final onProgressChanged = args['onProgressChanged'] as VoidCallback?;

        return _createRoute(SectionsScreen(
          technology: technology,
          onTechnologyProgressChanged: onProgressChanged,
        ));
      default:
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}