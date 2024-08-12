import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:razorpay/Services/Profile.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double selectedAmount = 0;
  final GlobalKey<FormState> _formkey = GlobalKey();
  TextEditingController amountController = TextEditingController();
  late Razorpay _razorpay;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    amountController.text = selectedAmount.toStringAsFixed(0);
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  void dispose() {
    _razorpay.clear();
    amountController.dispose();
    super.dispose();
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success");
    String paymentId =
        response.paymentId ?? ""; // Default to empty string if null
    if (paymentId.isNotEmpty) {
      try {
        await savePaymentDetails(
            paymentId, double.parse(amountController.text));

        // Get.off(() => Splashscreen2());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Payment of ₹${selectedAmount.toStringAsFixed(0)} was successful."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print("Error in payment handling: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred while processing your payment."),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        amountController.clear();
      }
    } else {
      print("Payment ID is null or empty");
    }
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    print("Payment Failed: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  Future<void> savePaymentDetails(String paymentId, double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection("Payments")
        .doc(paymentId)
        .set({
      'payment_id': paymentId,
      'amount': amount,
      'user': user.phoneNumber, // Fetching the phone number
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void updateSelectedAmount(double amount) {
    setState(() {
      selectedAmount = amount;
      amountController.text = amount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var b = snapshot.data!;
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 170, 0, 255),
                title: Text('Razor Pay'),
                actions: [
                  InkWell(
                    onTap: () {
                      Get.to(ProfileScreen(
                        id: b.id.toString(),
                      ));
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Gap(30)
                ],
              ),
              body: Form(
                key: _formkey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => updateSelectedAmount(100),
                              child: Text('₹100'),
                            ),
                            ElevatedButton(
                              onPressed: () => updateSelectedAmount(200),
                              child: Text('₹200'),
                            ),
                            ElevatedButton(
                              onPressed: () => updateSelectedAmount(500),
                              child: Text('₹500'),
                            ),
                            ElevatedButton(
                              onPressed: () => updateSelectedAmount(1000),
                              child: Text('₹1000'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: amountController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the amount";
                            }
                            double? amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return "Please enter a valid amount";
                            }
                            return null;
                          },
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Enter Amount',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            try {
                              selectedAmount = double.parse(value);
                            } catch (e) {
                              selectedAmount = 0.0;
                            }
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (!_formkey.currentState!.validate()) {
                              return;
                            }
                            _formkey.currentState!.save();
                            var options = {
                              "key": "rzp_test_voBuMN7ZlM8kaE",
                              "amount": num.parse(amountController.text) * 100,
                              "name": "Start Projects",
                              "description": "Payment for our work",
                              "prefill": {
                                "contact": currentUser.phoneNumber ?? "N/A",
                                "email": currentUser.email ?? "N/A",
                              },
                              "external": {
                                "wallets": ["paytm"]
                              }
                            };
                            try {
                              _razorpay.open(options);
                            } catch (e) {
                              print(e.toString());
                            }
                            print('Selected amount: ₹$selectedAmount');
                          },
                          child:
                              Text('Add ₹${selectedAmount.toStringAsFixed(0)}'),
                        ),
                        SizedBox(height: 20),
                        StreamBuilder(
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
                              return Center(
                                  child: Text(
                                "No payments found",
                                style: TextStyle(color: Colors.white),
                              ));
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
                                    'Amount: ₹${payment["amount"]?.toStringAsFixed(0) ?? "N/A"}',
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:razorpay/splashScreen2.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:get/get.dart';

// class PaymentScreen extends StatefulWidget {
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   double selectedAmount = 200;
//   final GlobalKey<FormState> _formkey = GlobalKey();
//   TextEditingController amountController = TextEditingController();
//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     requestNotificationPermission();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
//     amountController.text = selectedAmount.toStringAsFixed(0);
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     amountController.dispose();
//     super.dispose();
//   }

//   void handlerPaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       // Check if paymentId is present
//       if (response.paymentId != null && response.paymentId!.isNotEmpty) {
//         await savePaymentDetails(response.paymentId!, double.parse(amountController.text));
//         await triggerNotifications(selectedAmount, response.paymentId!);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Payment of ₹${selectedAmount.toStringAsFixed(0)} was successful."),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception("Payment ID is null or empty");
//       }
//     } catch (e) {
//       print("Error in payment handling: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("An error occurred while processing your payment."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       amountController.clear();
//     }
//   }


//   void handlerErrorFailure(PaymentFailureResponse response) {
//     print("Payment Failed: ${response.message}");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Payment failed: ${response.message}"),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void handlerExternalWallet(ExternalWalletResponse response) {
//     print("External Wallet: ${response.walletName}");
//   }

//   Future<void> savePaymentDetails(String paymentId, double amount) async {
//     await FirebaseFirestore.instance.collection('payments').doc(paymentId).set({
//       'payment_id': paymentId,
//       'amount': amount,
//       'user': 'mathiyarasans2001@gmail.com', // Replace with the authenticated user's email
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//   //
//   // Future<void> saveNotificationDetails(String notificationId, double amount) async {
//   //   await FirebaseFirestore.instance.collection('notifications').doc(notificationId).set({
//   //     'notification_id': notificationId,
//   //     'amount': amount,
//   //     'timestamp': FieldValue.serverTimestamp(),
//   //   });
//   // }

//   Future<void> triggerNotifications(double amount, String paymentId) async {
//     String notificationId = "notif_${DateTime.now().millisecondsSinceEpoch}";

//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 0,
//         channelKey: "basic_channel",
//         title: "Payment Successful",
//         body: "Your payment of ₹${amount.toStringAsFixed(0)} was successful.",
//         notificationLayout: NotificationLayout.Default,
//         icon: 'resource://drawable/res_notification_icon', // Replace with your actual icon name
//       ),
//     );

//     // If you have a method for saving notification details, you can call it here
//     // await saveNotificationDetails(notificationId, amount);
//   }



//   void updateSelectedAmount(double amount) {
//     setState(() {
//       selectedAmount = amount;
//       amountController.text = amount.toStringAsFixed(0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Payment'),
//       ),
//       body: Form(
//         key: _formkey,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => updateSelectedAmount(100),
//                       child: Text('₹100'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => updateSelectedAmount(200),
//                       child: Text('₹200'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => updateSelectedAmount(500),
//                       child: Text('₹500'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => updateSelectedAmount(1000),
//                       child: Text('₹1000'),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 TextFormField(
//                   controller: amountController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter the amount";
//                     }
//                     double? amount = double.tryParse(value);
//                     if (amount == null || amount <= 0) {
//                       return "Please enter a valid amount";
//                     }
//                     return null;
//                   },
//                   keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
//                   ],
//                   decoration: InputDecoration(
//                     labelText: 'Enter Amount',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (value) {
//                     try {
//                       selectedAmount = double.parse(value);
//                     } catch (e) {
//                       selectedAmount = 0.0;
//                     }
//                     setState(() {});
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (!_formkey.currentState!.validate()) {
//                       return;
//                     }
//                     _formkey.currentState!.save();
//                     var options = {
//                       "key": "rzp_test_voBuMN7ZlM8kaE",
//                       "amount": num.parse(amountController.text) * 100, // amount in paise
//                       "name": "Start Projects",
//                       "description": "Payment for our work",
//                       "prefill": {
//                         "contact": "6383185407",
//                         "email": "mathiyarasans2001@gmail.com" // Replace with authenticated user's email
//                       },
//                       "external": {
//                         "wallets": ["paytm"]
//                       }
//                     };

//                     try {
//                       _razorpay.open(options);
//                     } catch (e) {
//                       print(e.toString());
//                     }
//                     print('Selected amount: ₹$selectedAmount');
//                   },
//                   child: Text('Add ₹${selectedAmount.toStringAsFixed(0)}'),
//                 ),
//                 SizedBox(height: 20),
//                 StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('payments')
//                       .orderBy('timestamp', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return CircularProgressIndicator();
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Text('No payments found');
//                     }
//                     final payments = snapshot.data!.docs;
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: payments.length,
//                       itemBuilder: (context, index) {
//                         final payment = payments[index];
//                         final amount = payment['amount'] ?? 0.0;
//                         final timestamp = (payment['timestamp'] as Timestamp?)?.toDate();
//                         return ListTile(
//                           title: Text('Payment of ₹${amount.toStringAsFixed(0)}'),
//                           subtitle: timestamp != null
//                               ? Text('Timestamp: ${DateFormat.yMd().add_jm().format(timestamp)}')
//                               : Text('Timestamp: N/A'),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> requestNotificationPermission() async {
//     await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
//       if (!isAllowed) {
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//   }
// }
