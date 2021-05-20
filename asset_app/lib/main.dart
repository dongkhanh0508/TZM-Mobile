import 'package:asset_app/config_base.dart';
import 'package:asset_app/general_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Application',
      theme: ThemeData(
        primaryColor: Config.secondColor,
        fontFamily: 'OpenSans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Config.swatchTimePickerColor,
      ),
      home: LoginScreen(),
    );
  }
}
