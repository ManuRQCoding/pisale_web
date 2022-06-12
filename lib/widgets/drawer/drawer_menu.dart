import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pisale_web/properties.dart';
import 'package:pisale_web/widgets/drawer/menu_item.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Color(
        palette['primary']!,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MENU ADMINISTRADOR',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -11,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.menu,
                      color: Color(palette['secondary']!),
                    )),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Divider(
            color: Colors.white54,
            height: 0,
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              MenuItemWidget(
                title: 'Tests',
                route: 'tests',
                icon: Icons.question_mark_rounded,
              ),
              Divider(
                color: Colors.white54,
                height: 0,
              ),
              MenuItemWidget(
                  title: 'Rutas', route: 'routes', icon: Icons.route_rounded),
              Divider(
                color: Colors.white54,
                height: 0,
              ),
              MenuItemWidget(
                  title: 'Usuarios', route: 'users', icon: Icons.people),
            ],
          )
        ],
      ),
    );
  }
}
