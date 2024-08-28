import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay/Services/LoginPage/OtpScreen.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(100),
              Center(
                child: Text(
                  "Go to Login Page",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Color(0XFF3D4A7A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Welcome to Razor Pay",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0XFF797C7B),
                ),
              ),
              Gap(100),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Number"),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please fill the Field";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  controller: phoneNumberController,
                  decoration: InputDecoration(),
                ),
              ),
              Gap(30),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(300, 48),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xff3e0172),
                ),
                onPressed: () {
              if(_formkey.currentState!.validate()){
                Get.to(OtpSreen(
                  Phonenumber: phoneNumberController.text,
                ));
              }
                  // Get.to(OtpSreen(
                  //   Phonenumber: phoneNumberController.text,
                  // ));
                },
                child: Text(
                  "Log in",
                  style: GoogleFonts.stoke(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Gap(50),
              // Center(
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       SizedBox(
              //         child: Divider(),
              //         width: 130,
              //       ),
              //       Text("or"),
              //       SizedBox(
              //         child: Divider(),
              //         width: 130,
              //       ),
              //     ],
              //   ),
              // ),
              // Gap(50),

              // InkWell(
              //   onTap: () async {
              //     try {
              //       final GoogleSignInAccount? googleUser =
              //           await _googleSignIn.signIn();
              //       if (googleUser != null) {
              //         final GoogleSignInAuthentication googleAuth =
              //             await googleUser.authentication;
              //         final AuthCredential credential =
              //             GoogleAuthProvider.credential(
              //           accessToken: googleAuth.accessToken,
              //           idToken: googleAuth.idToken,
              //         );

              //         final UserCredential userCredential =
              //             await _auth.signInWithCredential(credential);
              //         final User? currentUser = userCredential.user;

              //         if (currentUser != null) {
              //           final DocumentSnapshot snapshot = await FirebaseFirestore
              //               .instance
              //               .collection("Users")
              //               .doc(FirebaseAuth.instance.currentUser!.uid)
              //               .get();

              //           if (snapshot.exists) {
              //             Get.to(PaymentScreen(

              //             ));
              //           } else {
              //             Get.to(DetailsPage(
              //               phonenumber: phoneNumberController.text,
              //               Email: currentUser.email ?? "",
              //             ));
              //           }
              //         }
              //       }
              //     } on FirebaseAuthException catch (e) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //           content: Text("Firebase Auth Exception: ${e.message}"),
              //         ),
              //       );
              //     } catch (e) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //           content: Text("Error: $e"),
              //         ),
              //       );
              //     }
              //   },
              //   child: CircleAvatar(
              //     radius: 30,
              //     backgroundColor: Colors.black,
              //     child: Image.asset("asset/Group 438.png"),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
