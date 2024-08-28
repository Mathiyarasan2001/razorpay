import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay/Services/LoginPage/DetailsScreen.dart';
import 'package:razorpay/Services/SelectPayment.dart';

class OtpSreen extends StatefulWidget {
  final String Phonenumber;

  const OtpSreen({
    super.key,
    required this.Phonenumber,
  });

  @override
  State<OtpSreen> createState() => _OtpSreenState();
}

class _OtpSreenState extends State<OtpSreen> {
  String? _verificationCode;
  final TextEditingController _pinput = TextEditingController();

  @override
  void initState() {
    super.initState();
    verifyPhonenumber();
  }

  Future<void> verifyPhonenumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${widget.Phonenumber}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) async {
          final User? user = FirebaseAuth.instance.currentUser;
          final uid = user!.uid;
          var im = await FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .get();
          if (im.exists) {
            Get.off(PaymentScreen());
          } else {
            Get.off(DetailsPage(
              Email: user.email ?? "",
              phonenumber: widget.Phonenumber,
            ));
          }
        });                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
      },
      verificationFailed: (FirebaseAuthException e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(e.message ?? "Verification Failed"),
            );
          },
        );
      },
      codeSent: (String verificationID, int? resendToken) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> submitOtp() async {
    final credential = PhoneAuthProvider.credential(
        verificationId: _verificationCode!, smsCode: _pinput.text);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      final curentuser = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(curentuser!.uid)
          .get();
      if (snapshot.exists) {
        Get.off(() => PaymentScreen());
      } else {
        Get.off(() => DetailsPage(
              Email: curentuser.email ?? "",
              phonenumber: widget.Phonenumber,
            ));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 1000,
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Gap(100),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text("Otp Verification",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3D4A7A),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 20, right: 25, bottom: 50),
              child: Text(
                "Enter the verification code we just sent on your phone number",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              child: PinCodeTextField(
                controller: _pinput,
                onCompleted: (v) {
                  // // Auto submit OTP when all digits are entered
                  // _submitOtp();
                },
                enableActiveFill: true,
                enabled: true,
                showCursor: false,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.green,
                  selectedFillColor: Colors.white,
                  inactiveColor: Color.fromARGB(255, 16, 91, 148),
                  activeFillColor: Colors.white,
                  inactiveFillColor: const Color.fromARGB(255, 222, 222, 222),
                  activeColor: Colors.red,
                ),
                appContext: context,
                length: 6,
              ),
            ),
            Center(
                child: TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(300, 48),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Color(0xff3e0172),
              ),
              onPressed: submitOtp,
              child: Text("Submit",
                  style: GoogleFonts.stoke(
                    fontSize: 16,
                    color: Colors.white,
                  )),
            )),
          ],
        ),
      ),
    );
  }
}
