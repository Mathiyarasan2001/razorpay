import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay/SelectPayment.dart';

class Splashscreen2 extends StatefulWidget {
  const Splashscreen2({super.key});

  @override
  State<Splashscreen2> createState() => _Splashscreen2State();
}

class _Splashscreen2State extends State<Splashscreen2> {
  _startTimer() async {
    await Timer(
      Duration(seconds: 8),
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
        child: Center(child: Lottie.asset("asset/2.json", fit: BoxFit.cover)),
      ),
    );
  }
}
