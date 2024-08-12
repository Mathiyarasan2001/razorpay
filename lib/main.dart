// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:razorpay/SelectPayment.dart';
// import 'package:razorpay/firebase_options.dart';
// import 'package:razorpay/homePage.dart';
// import 'package:razorpay/notifi.dart';
// import 'package:razorpay/splashScreen.dart';
//
// void main() async {
//   AwesomeNotifications().initialize(null, [
//     NotificationChannel(
//       channelKey: 'basic_channel',
//       channelName: 'Basic notifications',
//       channelDescription: 'Notification channel for basic notifications',
//       defaultColor: Color(0xFF9D50DD),
//       ledColor: Colors.white,
//     )
//   ]);
//
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'RAZOR PAY',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: Splashscreen(),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay/Services/LoginPage/splashScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Razor Pay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splashscreen(),
    );
  }
}
