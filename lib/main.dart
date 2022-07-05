import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/screens/root/root_screen.dart';

import 'generated/l10n.dart';

void main() async {
  await initHiveForFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>(
              create: (_) => AuthController())
        ],
        builder: (context, child) {
          return MaterialApp(
            title: 'Triple S',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: Color(0xff6659FF),
                backgroundColor: Colors.white,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: AppBarTheme(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Color(0xff6659FF)))),
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: RootScreen(),
          );
        });
  }
}
