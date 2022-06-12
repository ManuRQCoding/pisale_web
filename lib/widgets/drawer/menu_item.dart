import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget(
      {Key? key, required this.title, required this.route, required this.icon})
      : super(key: key);

  final String title;
  final String route;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white54,
              size: 18,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
