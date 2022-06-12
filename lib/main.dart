import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pisale_web/pages/home_page.dart';
import 'package:pisale_web/pages/login/login_page.dart';
import 'package:pisale_web/pages/routes/providers/edit_route_provider.dart';
import 'package:pisale_web/pages/routes/providers/remove_routes_provider.dart';
import 'package:pisale_web/pages/routes/routes_page.dart';
import 'package:pisale_web/pages/tests/providers/edit_question_provider.dart';
import 'package:pisale_web/pages/tests/providers/question_provider.dart';
import 'package:pisale_web/pages/tests/providers/remove_questions_provider.dart';
import 'package:pisale_web/pages/tests/providers/remove_test_provider.dart';
import 'package:pisale_web/pages/tests/providers/remove_themes_provider.dart';
import 'package:pisale_web/pages/tests/tests_page.dart';
import 'package:pisale_web/pages/users/providers/remove_users.dart';
import 'package:pisale_web/pages/users/users_page.dart';
import 'package:pisale_web/properties.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StateApp());
}

class StateApp extends StatelessWidget {
  const StateApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => RemoveTestsProv()),
      ChangeNotifierProvider(create: (context) => RemoveThemesProv()),
      ChangeNotifierProvider(create: (context) => RemoveQuestionsProv()),
      ChangeNotifierProvider(create: (context) => RemoveRoutesProv()),
      ChangeNotifierProvider(create: (context) => RemoveUsersProv()),
      ChangeNotifierProvider(create: (context) => QuestionProvider()),
      ChangeNotifierProvider(create: (context) => EditRouteProvider()),
      ChangeNotifierProvider(create: (context) => EditQuestionProvider()),
    ], child: MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        checkboxTheme: CheckboxThemeData(
          side: MaterialStateBorderSide.resolveWith(
              (_) => BorderSide(width: 1, color: Color(palette['primary']!))),
          fillColor: MaterialStateProperty.all(Color(palette['secondary']!)),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(palette['primary']!),
          onPrimary: Colors.white,
          secondary: Color(palette['secondary']!),
          onSecondary: Color(palette['secondary']!),
          error: Colors.red,
          onError: Colors.white,
          background: Color(palette['background']!),
          onBackground: Colors.white,
          surface: Color(palette['background']!),
          onSurface: Color(palette['background']!),
          tertiary: Color(palette['tertiary']!),
        ),
        primaryColor: Color(palette['primary']!),
      ),
      initialRoute: 'login',
      routes: {
        'login': (_) => LoginPage(),
        'tests': (_) => TestsPage(),
        'users': (_) => UsersPage(),
        'routes': (_) => RoutesPage(),
      },
    );
  }
}
