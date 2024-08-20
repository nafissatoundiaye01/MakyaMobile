import 'package:cafetariat/slider.dart';
import 'package:cafetariat/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connexion.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Cafetariat',
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const HomeScreen(),
      routes: {
        '/second': (context) => SecondPage(),
        '/slider': (context) => SliderPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    //logout();
    checkLoginStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Durée de l'animation
    );

    _sizeAnimation =
        Tween<double>(begin: 150.0, end: 250.0).animate(_animationController);

    _animationController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              isLoggedIn ? SecondPage() : SliderPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0), // Starting position (bottom)
                end: Offset.zero, // Ending position (top)
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(
              milliseconds: 3000), // Durée de l'animation de transition
        ),
      );
    });
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    setState(() {
      isLoggedIn = true;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 211, 100, 9), // Couleur d'arrière-plan
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CircleAvatar(
                radius: _sizeAnimation.value / 2,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage(
                    'assets/images/home.png'), // Spécifiez le chemin de votre image
              );
            },
          ),
        ),
      ),
    );
  }
}
