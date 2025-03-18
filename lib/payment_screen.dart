import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rent_app/track_order.dart'; // Adjust this import path as needed

class PaymentScreen extends StatefulWidget {
  final dynamic item;

  const PaymentScreen({Key? key, required this.item}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Date selection controllers
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  // Razorpay instance
  late Razorpay _razorpay;

  // User information controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Focus nodes for input fields
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  // Number of days for rental (default: 1)
  int _rentalDays = 1;

  @override
  void initState() {
    super.initState();

    // Set default from date to today
    _fromDateController.text = DateTime.now().toString().split(' ')[0];
    // Set default to date to tomorrow
    _toDateController.text =
        DateTime.now().add(Duration(days: 1)).toString().split(' ')[0];

    // Initialize Razorpay
    _initializeRazorpay();

    // Set focus on the first input field
    _nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _razorpay.clear(); // Clear all Razorpay event listeners
    super.dispose();
  }

  // Initialize Razorpay
  void _initializeRazorpay() {
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      print("Razorpay initialized successfully");
    } catch (e) {
      print("Error initializing Razorpay: $e");
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    String bookingId =
        DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Payment Successful!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text("Your rental has been confirmed."),
            SizedBox(height: 8),
            Text(
              "Booking ID: #$bookingId",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Payment ID: ${response.paymentId}",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to tracking screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderTrackingScreen(
                    bookingId: bookingId,
                    item: widget.item,
                    fromDate: DateTime.parse(_fromDateController.text),
                    toDate: DateTime.parse(_toDateController.text),
                  ),
                ),
              );
            },
            child: Text("TRACK ORDER"),
          ),
          TextButton(
            onPressed: () {
              // Navigate back to home
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            child: Text("RETURN TO HOME"),
          ),
        ],
      ),
    );
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message ?? 'Error occurred'}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External wallet selected: ${response.walletName}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  // Open Razorpay checkout
  void _openRazorpayCheckout() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all the required fields",
        backgroundColor: Colors.red,
      );
      return;
    }

    // Convert amount to smallest currency unit (paise for INR)
    int amountInPaise = (_calculateTotal() * 100).toInt();

    var options = {
      'key': 'rzp_test_FTgfbzcexiSzKO', // Replace with your Razorpay key
      'amount': amountInPaise,
      'name': 'Rent App',
      'description': 'Payment for ${widget.item['title']} rental',
      'prefill': {
        'name': _nameController.text,
        'email': _emailController.text,
        'contact': _phoneController.text,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    }
  }

  // Calculate totals based on rental days
  double _calculateRentalFee() {
    return double.parse(widget.item['price'].toString()) * _rentalDays;
  }

  double _calculateSecurityDeposit() {
    return double.parse(widget.item['price'].toString()) * 0.5;
  }

  double _calculateServiceFee() {
    return _calculateRentalFee() * 0.1;
  }

  double _calculateTotal() {
    return _calculateRentalFee() +
        _calculateSecurityDeposit() +
        _calculateServiceFee();
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isFromDate) async {
    DateTime initialDate = DateTime.now();
    if (isFromDate && _toDateController.text.isNotEmpty) {
      // Don't allow from date to be after to date
      DateTime toDate = DateTime.parse(_toDateController.text);
      if (toDate.isBefore(initialDate)) {
        initialDate = toDate;
      }
    } else if (!isFromDate && _fromDateController.text.isNotEmpty) {
      // Don't allow to date to be before from date
      DateTime fromDate = DateTime.parse(_fromDateController.text);
      initialDate = fromDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isFromDate
          ? DateTime.now()
          : DateTime.parse(_fromDateController.text),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(' ')[0]; // YYYY-MM-DD format

        // Calculate rental days
        if (_fromDateController.text.isNotEmpty &&
            _toDateController.text.isNotEmpty) {
          DateTime fromDate = DateTime.parse(_fromDateController.text);
          DateTime toDate = DateTime.parse(_toDateController.text);
          _rentalDays =
              toDate.difference(fromDate).inDays + 1; // Include both days
          if (_rentalDays < 1) _rentalDays = 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Payment",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.item['image'],
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "₹${widget.item['price']}/day",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                widget.item['location'],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Payment details form
            Text(
              "Payment Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Rental period
            Text(
              "Rental Period",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "From Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () {
                      _selectDate(context, _fromDateController, true);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _toDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "To Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () {
                      _selectDate(context, _toDateController, false);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                "Total rental period: $_rentalDays day${_rentalDays != 1 ? 's' : ''}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            SizedBox(height: 24),

            // User details for Razorpay
            Text(
              "Contact Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              autofocus: true, // Ensure this field is focused initially
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 32),

            // Order summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Rental Fee (₹${widget.item['price']} × $_rentalDays days)"),
                        Text("₹${_calculateRentalFee().toStringAsFixed(2)}"),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Security Deposit"),
                        Text(
                            "₹${_calculateSecurityDeposit().toStringAsFixed(2)}"),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Service Fee"),
                        Text("₹${_calculateServiceFee().toStringAsFixed(2)}"),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹${_calculateTotal().toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Pay now button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _openRazorpayCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Pay with Razorpay",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Track order button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Navigate to tracking screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(
                        bookingId: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString()
                            .substring(5, 13),
                        item: widget.item,
                        fromDate: DateTime.parse(_fromDateController.text),
                        toDate: DateTime.parse(_toDateController.text),
                      ),
                    ),
                  );
                },
                child: Text("TRACK ORDER"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
