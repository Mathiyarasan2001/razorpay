import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:razorpay/Services/LoginPage/LoginPage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.id});
  final String id;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.id.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var b = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text("Profile"),
                actions: [
                  InkWell(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Get.off(Signin());
                      },
                      child: Icon(Icons.login)),
                  SizedBox(
                    width: 50,
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gap(50),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            color: Colors.black,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Gap(30),
                              Text(
                                "Name: ${b["Name"]}",
                                style: TextStyle(fontSize: 18),
                              ),
                              Gap(10),
                              Text(
                                "Name: ${b["Number"]}",
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          )
                        ],
                      ),
                      Gap(30),
                      Center(
                        child: Container(
                            height: 50,
                            width: 400,
                            color: Colors.black,
                            child: Center(
                              child: Text(
                                "See History",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            )),
                      ),
                      Gap(20),
                      Center(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection("Payments")
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            }

                            final payments = snapshot.data?.docs;

                            if (payments == null || payments.isEmpty) {
                              return Center(child: Text("No payments found"));
                            }

                            return ListView.builder(
                              itemBuilder: (context, index) {
                                var payment = payments[index];
                                bool isCredit = payment["amount"] != null &&
                                    payment["amount"] > 0;

                                Timestamp? timestamp =
                                    payment["timestamp"] is Timestamp
                                        ? payment["timestamp"] as Timestamp
                                        : null;
                                String formattedDate = timestamp != null
                                    ? DateFormat('yyyy-MM-dd – hh:mm a')
                                        .format(timestamp.toDate())
                                    : "N/A";

                                return ListTile(
                                  title: Text(
                                      'Amount: ₹${payment["amount"]?.toStringAsFixed(0) ?? "N/A"}'),
                                  subtitle: Text('Date: $formattedDate'),
                                  leading: Icon(
                                    isCredit
                                        ? Iconsax.money_send
                                        : Iconsax.minus,
                                    color: Colors.red,
                                  ),
                                );
                              },
                              itemCount: payments.length,
                              shrinkWrap: true,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
