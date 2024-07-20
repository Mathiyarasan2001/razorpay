import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay/SelectPayment.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  _startTimer() async {
    await Timer(
      Duration(seconds: 3),
      () => Get.off(PaymentScreen()),
    );
  }

  @override
  void initState() {
    _startTimer();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 300,
        width: 300,
        child: Center(child: Lottie.asset("asset/3.json", fit: BoxFit.cover)),
      ),
    );
  }
}
