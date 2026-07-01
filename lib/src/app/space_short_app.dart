import 'package:flutter/material.dart';

import '../ui/main_menu_page.dart';

class SpaceShortApp extends StatelessWidget {
  const SpaceShortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Space Short',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainMenuPage(),
    );
  }
}
