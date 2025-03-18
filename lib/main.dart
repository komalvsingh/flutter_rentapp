import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rent_app/splashscreen.dart';

import 'firebase_options.dart'; // Ensure this is the correct import for firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Stripe.publishableKey = publishable_key;
  // await Stripe.instance.applySettings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent-A-Vibe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
