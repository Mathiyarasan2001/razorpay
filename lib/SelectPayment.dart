import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay/splashScreen2.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // Import Get package

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double selectedAmount = 200; // To store the selected amount

  final GlobalKey<FormState> _formkey = GlobalKey();
  TextEditingController amountController = TextEditingController();
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    amountController.text = selectedAmount.toStringAsFixed(0);
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

    Get.off(() => Splashscreen2());
    amountController.clear();
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    print("Payment Failed");
    setState(() {});
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print("External Wallet");
    setState(() {});
  }

  Future<void> savePaymentDetails(String? paymentId, double amount) async {
    await FirebaseFirestore.instance.collection('payments').doc(paymentId).set({
      'payment_id': paymentId,
      'amount': amount,
      'user': 'mathiyarasans2001@gmail.com',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Row for preset amount buttons
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
                SizedBox(height: 20), // Space between row and text field
                // Text field for custom amount
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
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
                SizedBox(height: 20), // Space between text field and button
                // Add button with dynamic text
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
                    print('Selected amount: ₹$selectedAmount');
                  },
                  child: Text(
                    'Add ₹${selectedAmount.toStringAsFixed(0)}',
                  ),
                ),
                SizedBox(height: 20), // Space before payment history
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
                            isCredit
                                ? Iconsax.money_send
                                : Iconsax.money_recive,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
