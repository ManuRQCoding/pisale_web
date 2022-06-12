import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pisale_web/properties.dart';

import '../widgets/drawer/drawer_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(palette['background']!),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(palette['secondary']!),
      ),
      drawer: DrawerMenu(),
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Color(palette['background']!),
            ),
          ),
        ],
      ),
    );
  }
}
