import 'dart:convert';
import 'openurl.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/screens/school_fee.dart';
import 'package:careerapp/services/api_services.dart';

class StudentCanteenReport extends StatefulWidget {
  static const routeName = '/StudentCanteenReport';

  const StudentCanteenReport({Key? key}) : super(key: key);

  @override
  _StudentCanteenReportState createState() => _StudentCanteenReportState();
}

class _StudentCanteenReportState extends State<StudentCanteenReport> {
  var data6 = [];
  var data7 = [];
  var balance = '0';
  var pocket_money = '0';
  var student_name = '';
  var heading = "Pocket Money";
  Color primaryColor = const Color(0xFF1E88E5);
  Color secondaryColor = const Color(0xFF42A5F5);
  Color accentColor = const Color(0xFFFF9800);
  Color textColor = const Color(0xff2A2E48);
  Color backgroundColor = const Color(0xFFF8F8FA);
  List<Widget> tilesList = [];
  List<Widget> medicalTilesList = [];
  dynamic data = {};
  
  // Transaction summary
  double totalCanteenSpent = 0;
  double totalMedicalSpent = 0;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      balance = data["balance"];
      pocket_money = data["pocket_money"];
      student_name = data["first_name"];
      getCanteenData();
      getMedicalData();
      setState(() {});
    });
  }

  getCanteenData() async {
    var res =
        await ApiService.getMethod3("/getCanteenOrders?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    data6 = d["data"];
    
    // Calculate total spent on canteen
    totalCanteenSpent = 0;
    for (var item in data6) {
      totalCanteenSpent += double.parse(item["totals"] ?? "0");
    }
    
    tilesList = data6.asMap().entries.map<Widget>((e) {
      var todo = e.value;
      return listTile(
        productName: todo['student_name'] ?? '',
        price: todo["totals"] ?? '',
        created: todo["date"] ?? '',
        orderNo: todo["order_no"] ?? '',
        image: todo["image"],
      );
    }).toList();

    setState(() {});
  }

  getMedicalData() async {
    var res = await ApiService.getMethod3("/getMedicalReport?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    var medicalData = d["data"];

    if (medicalData != null && medicalData.isNotEmpty) {
      // Calculate total spent on medical
      totalMedicalSpent = 0;
      for (var item in medicalData) {
        totalMedicalSpent += double.parse(item["total_fee"] ?? "0");
      }
      
      setState(() {
        medicalTilesList = medicalData.asMap().entries.map<Widget>((e) {
          var todo = e.value;
          return listTile(
            productName: todo['sick'] ?? '',
            price: todo["total_fee"] ?? '',
            created: todo["created"] ?? '',
            orderNo: todo["id"] ?? '',
            isMedical: true, 
          );
        }).toList();
      });
    }
  }

  loadData(orderno) async {
    var res = await ApiService.getMethod3(
        "/getCanteenOrderItems?order_no=" + orderno);
    dynamic d = jsonDecode(res.body);
    data7 = d["data"];
    _showMyDialog();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = totalCanteenSpent + totalMedicalSpent;
    double remainingBalance = double.parse(balance);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          heading,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              getCanteenData();
              getMedicalData();
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Top curved background
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              color: primaryColor,
            ),
          ),
          
          // Main content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  
                  // Pocket Money Card
                  Container(
                    padding: EdgeInsets.all(3.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $student_name',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Current Balance(Pocket Money Non Refundable)',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              radius: 20,
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 2.h),
                        // Text(
                        //   '₹ $balance',
                        //   style: TextStyle(
                        //     color: primaryColor,
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 24.sp,
                        //   ),
                        // ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Schoolfee(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.5.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Add Money',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            if (pocket_money != '0')
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total Pocket Money',
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                    Text(
                                      '₹ $pocket_money',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
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
                  
                  SizedBox(height: 3.h),
                  
                  // Spending Summary
                  Container(
                    padding: EdgeInsets.all(3.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spending Summary',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              'Canteen',
                              '₹ ${totalCanteenSpent.toStringAsFixed(2)}',
                              Icons.fastfood,
                              primaryColor,
                            ),
                            _buildSummaryItem(
                              'Medical',
                              '₹ ${totalMedicalSpent.toStringAsFixed(2)}',
                              Icons.medical_services,
                              Colors.red,
                            ),
                            _buildSummaryItem(
                              'Total',
                              '₹ ${totalSpent.toStringAsFixed(2)}',
                              Icons.account_balance,
                              accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Fixed Charges
                  Container(
                    padding: EdgeInsets.all(3.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: primaryColor),
                            SizedBox(width: 2.w),
                            Text(
                              'Fixed Charges',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "1. Hair Cut Charges Rs 500/-Year\n2. Weekly 3 Heavy Snacks Charges Rs 200/-\n3. Monthly Snacks Rs 800/-\n4. Per Educational Trip Rs 500 to 1000/-\n5. Per Function Charges Rs 500/-\n6. School Books, Dress & Stationary Rs 10,000/-\n7. NCC Students Dress & Shoes Rs 2,500/-\n8. Quarterly Medical Charges Rs 500/-\n9. Super 50 Sports Extra Diet Milk & Fruits Monthly Rs 2000/- ",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textColor.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Transaction History
                  Text(
                    'Transaction History',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  
                  // Tabs for Canteen and Medical
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: primaryColor,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: textColor,
                            tabs: [
                              Tab(text: 'Canteen (${tilesList.length})'),
                              Tab(text: 'Medical (${medicalTilesList.length})'),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          height: 50.h,
                          child: TabBarView(
                            children: [
                              // Canteen Transactions
                              tilesList.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_long,
                                            size: 50,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          SizedBox(height: 1.h),
                                          Text(
                                            'No canteen transactions yet',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView(
                                      physics: const BouncingScrollPhysics(),
                                      children: tilesList,
                                    ),
                              
                              // Medical Transactions
                              medicalTilesList.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.medical_services,
                                            size: 50,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          SizedBox(height: 1.h),
                                          Text(
                                            'No medical transactions yet',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView(
                                      physics: const BouncingScrollPhysics(),
                                      children: medicalTilesList,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          amount,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

 Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.receipt, color: primaryColor),
            SizedBox(width: 2.w),
            Text(
              'Order Details',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 20.h, // Adjust height as needed
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        '₹ ${_calculateTotal()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                DataTable(
                  columnSpacing: 20,
                  headingRowHeight: 40,
                  horizontalMargin: 5,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => primaryColor,
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.grey.withOpacity(0.1)
                        : null,
                  ),
                  border: TableBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Price')),
                  ],
                  rows: data7
                      .map(
                        ((element) => DataRow(
                              cells: <DataCell>[
                                DataCell(Text(
                                  (data7.indexOf(element) + 1).toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                )),
                                DataCell(Text(element["product_name"])),
                                DataCell(Text(element["qty"])),
                                DataCell(Text(
                                  "₹" + element["price"],
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                              ],
                            )),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Close',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  String _calculateTotal() {
    double total = 0;
    for (var item in data7) {
      total += double.parse(item["price"] ?? "0") * int.parse(item["qty"] ?? "1");
    }
    return total.toStringAsFixed(2);
  }

  Widget listTile({
    String? productName,
    String? price,
    String? created,
    String? orderNo,
    String? image,
    bool isMedical = false,
  }) {
    // Format date if possible
    String formattedDate = created ?? '';
    try {
      DateTime dateTime = DateTime.parse(created ?? '');
      formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      // Use original string if parsing fails
    }

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
        leading: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: isMedical ? Colors.red.withOpacity(0.1) : primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: GestureDetector(
                    child: Image.network(
                      '${ApiService.careerdefenceacademy2}includes/uploads/canteen_images/$image',
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      dynamic data3 = {
                        "school_name": "Pocket Money",
                        "url": "${ApiService.careerdefenceacademy2}includes/uploads/canteen_images/$image"
                      };
                      Navigator.of(context)
                          .pushNamed(OpenUrl.routeName, arguments: data3);
                    },
                  ),
                )
              : Center(
                  child: Icon(
                    isMedical ? Icons.medical_services : Icons.fastfood,
                    color: isMedical ? Colors.red : primaryColor,
                    size: 20.sp,
                  ),
                ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isMedical ? (productName ?? 'Medical Service') : 'Canteen Order',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '₹ ${price ?? '0'}',
              style: TextStyle(
                fontSize: 12.sp,
                color: isMedical ? Colors.red : primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
                if (!isMedical)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: isMedical ? null : () => loadData(orderNo),
      ),
    );
  }
}

