// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   final GlobalKey<FormState> _formkey = GlobalKey();
//   TextEditingController amountController = TextEditingController();
//   late Razorpay _razorpay;
//   @override
//   void initState() {
//     amountController;
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     amountController.dispose();
//     super.dispose();
//   }

//   void handlerPaymentSuccess() {
//     print("Payment Success");
//   }

//   void handlerErrorFailure() {
//     print("Payment Failed");
//   }

//   void handlerExternalWallet() {
//     print("External Wallet");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Razor Pay"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formkey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 200,
//               ),
//               Center(
//                 child: SizedBox(
//                   height: 50,
//                   width: 250,
//                   child: TextFormField(
//                     decoration: InputDecoration(hintText: "Enter the Amount"),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "please Enter the Amount";
//                       }
//                       return null;
//                     },
//                     controller: amountController,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               TextButton(
//                 style: TextButton.styleFrom(
//                     shape: ContinuousRectangleBorder(
//                         borderRadius: BorderRadius.circular(20)),
//                     backgroundColor: Colors.black,
//                     fixedSize: Size(150, 30)),
//                 onPressed: () {
//                   if (!_formkey.currentState!.validate()) {
//                     return;
//                   }
//                   _formkey.currentState!.save();
//                   var options = {
//                     "key": "rzp_test_voBuMN7ZlM8kaE",
//                     "amount": num.parse(amountController.text) * 100,
//                     "name": "Start Projects",
//                     "description": "Payment for our work",
//                     "prefill": {
//                       "contact": "6383185407",
//                       "email": "mathiyarasans2001@gmail.com"
//                     },
//                     "external": {
//                       "wallets": ["paytm"]
//                     }
//                   };
//                   try {
//                     _razorpay.open(options);
//                   } catch (e) {
//                     print(e.toString());
//                   }
//                 },
//                 child: Center(
//                   child: Text(
//                     "Pay Now",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<FormState> _formkey = GlobalKey();
  TextEditingController amountController = TextEditingController();
  late Razorpay _razorpay;

  @override
  void initState() {
    amountController;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    amountController.dispose();
    super.dispose();
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success");
    savePaymentDetails(response.paymentId, double.parse(amountController.text));
    amountController.clear();
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    print("Payment Failed");
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print("External Wallet");
  }

  Future<void> savePaymentDetails(String? paymentId, double amount) async {
    await FirebaseFirestore.instance.collection('payments').doc(paymentId).set({
      'payment_id': paymentId,
      'amount': amount,
      'user': 'mathiyarasans2001@gmail.com',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Razor Pay"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 250,
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Enter the Amount"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "please Enter the Amount";
                      }
                      return null;
                    },
                    controller: amountController,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.black,
                  fixedSize: Size(150, 30),
                ),
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
                      "contact": "6383185407",
                      "email": "mathiyarasans2001@gmail.com"
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
                },
                child: Center(
                  child: Text(
                    "Pay Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final payments = snapshot.data?.docs;

                  if (payments == null || payments.isEmpty) {
                    return Center(child: Text("No payments found"));
                  }

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      bool isCredit =
                          payment["amount"] != null && payment["amount"] > 0;

                      // Check if timestamp is not null and is of the correct type
                      Timestamp? timestamp = payment["timestamp"] is Timestamp
                          ? payment["timestamp"] as Timestamp
                          : null;

                      DateTime date = timestamp?.toDate() ?? DateTime.now();

                      String formattedDate =
                          DateFormat('dd.MM.yyyy').format(date);

                      return ListTile(
                        trailing: Text(
                          "₹ ${payment["amount"].toString()}",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        leading: Icon(
                          isCredit ? Iconsax.money_send : Iconsax.money_recive,
                          color: isCredit ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          formattedDate,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                    shrinkWrap: true,
                    itemCount: payments.length,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
