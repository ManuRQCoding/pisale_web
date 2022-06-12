import 'package:flutter/material.dart';
import 'package:pisale_web/pages/users/utils/users_utils.dart';
import 'package:pisale_web/properties.dart';
import 'package:pisale_web/widgets/drawer/drawer_menu.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color(palette['background']!),
        appBar: AppBar(
          backgroundColor: Color(palette['primary']!),
          elevation: 5,
          foregroundColor: Color(palette['secondary']!),
        ),
        drawer: DrawerMenu(),
        body: SingleChildScrollView(
          child: Column(
            children: [UsersUtils.usersStream(size)],
          ),
        ));
  }
}
