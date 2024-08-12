import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay/Services/SelectPayment.dart';

class DetailsPage extends StatefulWidget {
  DetailsPage({
    super.key,
    required this.phonenumber,
    required this.Email,
  });
  final String phonenumber;
  final String Email;
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> submit() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (nameController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          ageController.text.isNotEmpty ||
          numberController.text.isNotEmpty) {
        await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
          "Name": nameController.text,
          "Email": emailController.text,
          "Age": ageController.text,
          "Number": numberController.text,
        }, SetOptions(merge: true));
        print("User:$user");

        Get.offAll(PaymentScreen());
        nameController.clear();
        emailController.clear();
        ageController.clear();
        numberController.clear();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fill all required fields")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Data/account already exists, try to sign in")));
    }
  }

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController(text: widget.phonenumber);
    emailController = TextEditingController(text: widget.Email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(100),
            Center(
              child: Text("Fill the Details",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Color(0XFF3D4A7A),
                      fontWeight: FontWeight.bold)),
            ),
            Gap(30),
            Gap(50),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Align(alignment: Alignment.topLeft, child: Text("Name")),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(),
              ),
            ),
            Gap(30),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Align(alignment: Alignment.topLeft, child: Text("Number")),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: numberController,
                decoration: InputDecoration(),
              ),
            ),
            Gap(30),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Align(alignment: Alignment.topLeft, child: Text("Age")),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: ageController,
                decoration: InputDecoration(),
              ),
            ),
            Gap(30),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child:
                  Align(alignment: Alignment.topLeft, child: Text("E- Mail")),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(),
              ),
            ),
            Gap(30),
            TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(300, 48),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Color(0xff3e0172),
              ),
              onPressed: submit,
              child: Text("Submit",
                  style: GoogleFonts.stoke(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
            ),
            Gap(50),
          ],
        ),
      ),
    );
  }
}
