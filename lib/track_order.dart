import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String bookingId;
  final dynamic item;
  final DateTime fromDate;
  final DateTime toDate;

  const OrderTrackingScreen({
    Key? key,
    required this.bookingId,
    required this.item,
    required this.fromDate,
    required this.toDate,
  }) : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // In a real app, this would come from your backend
  // For demo purposes, we'll assume the order is in a specific state
  final int _currentStep = 2; // 0-based index of current step

  final List<Map<String, dynamic>> _trackingSteps = [
    {
      'title': 'Payment Confirmed',
      'description': 'Your payment has been processed successfully.',
      'icon': Icons.payment,
      'date': DateTime.now().subtract(Duration(hours: 1)),
      'isCompleted': true,
    },
    {
      'title': 'Item Prepared',
      'description': 'The owner is preparing your item for pickup/delivery.',
      'icon': Icons.inventory_2,
      'date': DateTime.now().subtract(Duration(minutes: 30)),
      'isCompleted': true,
    },
    {
      'title': 'Ready for Pickup/Delivery',
      'description': 'Your item is ready for pickup or being delivered.',
      'icon': Icons.local_shipping,
      'date': DateTime.now(),
      'isCompleted': true,
    },
    {
      'title': 'Item Handed Over',
      'description': 'You have received the item.',
      'icon': Icons.handshake,
      'date': null,
      'isCompleted': false,
    },
    {
      'title': 'Rental Period Active',
      'description': 'Your rental period is currently active.',
      'icon': Icons.access_time,
      'date': null,
      'isCompleted': false,
    },
    {
      'title': 'Return Initiated',
      'description': 'Item return process has been initiated.',
      'icon': Icons.keyboard_return,
      'date': null,
      'isCompleted': false,
    },
    {
      'title': 'Item Returned',
      'description': 'Item has been returned to the owner.',
      'icon': Icons.check_circle,
      'date': null,
      'isCompleted': false,
    },
    {
      'title': 'Security Deposit Refunded',
      'description': 'Your security deposit has been refunded.',
      'icon': Icons.account_balance_wallet,
      'date': null,
      'isCompleted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Order Tracking",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Container(
              color: Colors.deepPurple.withOpacity(0.1),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking ID: #${widget.bookingId}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.item['image'],
                          height: 70,
                          width: 70,
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
                            Text(
                              "Rental Period: ${_formatDate(widget.fromDate)} - ${_formatDate(widget.toDate)}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expected handover and return dates
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Timeline",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTimelineEvent(
                            "Item Handover",
                            _formatDate(widget.fromDate),
                            Icons.start,
                            Colors.blue,
                          ),
                          _buildTimelineEvent(
                            "Return Due",
                            _formatDate(widget.toDate),
                            Icons.flag,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tracking Timeline
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Order Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _trackingSteps.length,
                itemBuilder: (context, index) {
                  final step = _trackingSteps[index];
                  final isFirst = index == 0;
                  final isLast = index == _trackingSteps.length - 1;
                  final isActive = index <= _currentStep;

                  return TimelineTile(
                    isFirst: isFirst,
                    isLast: isLast,
                    beforeLineStyle: LineStyle(
                      color: index <= _currentStep
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                    ),
                    afterLineStyle: LineStyle(
                      color: index < _currentStep
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                    ),
                    indicatorStyle: IndicatorStyle(
                      width: 30,
                      height: 30,
                      indicator: Container(
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step['icon'],
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    endChild: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: EdgeInsets.only(left: 8, bottom: 16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.deepPurple.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                              ),
                              step['date'] != null
                                  ? Text(
                                      _formatTime(step['date']),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            step['description'],
                            style: TextStyle(
                              color: isActive
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Support button
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
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
                        "Need Help?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Contact our support team for any issues with your rental.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Handle chat support
                              },
                              icon: Icon(Icons.chat, color: Colors.deepPurple),
                              label: Text("Chat Support"),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle call support
                              },
                              icon: Icon(Icons.call),
                              label: Text("Call Support"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEvent(
      String title, String date, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
