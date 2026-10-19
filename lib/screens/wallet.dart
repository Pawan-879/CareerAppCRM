import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Wallet extends StatefulWidget {
  static const routeName = '/wallet';

  const Wallet({Key? key}) : super(key: key);

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  var data;
  var userData;

  var user_id = "";
  var balance = "0";
  var user_detail = {};
  var transactions = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      user_id = userData["user_id"];

      getUser(user_id);
      getWalletTransactions(user_id);
      setState(() {});
    }
  }

  getUser(id) async {
    var res2 = await ApiService.getMethod("/getUser?user_id=" + id);
    user_detail = jsonDecode(res2.body);
    balance = user_detail["balance"];
    print(user_detail);
    setState(() {});
  }

  getWalletTransactions(id) async {
    var res2 = await ApiService.getMethod("/wallet_transactions?user_id=" + id);
    transactions = jsonDecode(res2.body);

    print(user_detail);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(38, 81, 158, 1),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    size: 15, color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(height: 10),
                              const Text("Wallet",
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white))
                            ],
                          ),
                        ),
                        Column(children: [
                          Text(
                            balance,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "Available Points",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.blue[100]),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: <Widget>[
                    //     Container(
                    //       child: Column(
                    //         children: <Widget>[
                    //           Container(
                    //             decoration: const BoxDecoration(
                    //                 color: Color.fromRGBO(243, 245, 248, 1),
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(18))),
                    //             child: Icon(
                    //               Icons.date_range,
                    //               color: Colors.blue[900],
                    //               size: 30,
                    //             ),
                    //             padding: const EdgeInsets.all(12),
                    //           ),
                    //           const SizedBox(
                    //             height: 4,
                    //           ),
                    //           Text(
                    //             "Add Money",
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.w700,
                    //                 fontSize: 14,
                    //                 color: Colors.blue[100]),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Container(
                    //       child: Column(
                    //         children: <Widget>[
                    //           Container(
                    //             decoration: const BoxDecoration(
                    //                 color: Color.fromRGBO(243, 245, 248, 1),
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(18))),
                    //             child: Icon(
                    //               Icons.public,
                    //               color: Colors.blue[900],
                    //               size: 30,
                    //             ),
                    //             padding: const EdgeInsets.all(12),
                    //           ),
                    //           const SizedBox(
                    //             height: 4,
                    //           ),
                    //           Text(
                    //             "Withdrawal",
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.w700,
                    //                 fontSize: 14,
                    //                 color: Colors.blue[100]),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ),
              DraggableScrollableSheet(
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(243, 245, 248, 1),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  "All Transactions",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Colors.black),
                                ),
                                Text(
                                  "IN/OUT",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.grey[800]),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              return transaction(transactions[index]);
                            },
                            shrinkWrap: true,
                            itemCount: transactions.length,
                            padding: const EdgeInsets.all(0),
                            controller:
                                ScrollController(keepScrollOffset: false),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                initialChildSize: 0.80,
                minChildSize: 0.80,
                maxChildSize: 1,
              )
            ],
          ),
        ));
  }

  transaction(dynamic data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.all(Radius.circular(18))),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.date_range,
              color: Colors.lightBlue[900],
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data["description"],
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900]),
                ),
                Text(
                  data["created"],
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              data["type"] == "in"
                  ? Text(
                      "+" + data["amount"],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.lightGreen),
                    )
                  : Text(
                      "-" + data["amount"],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.red),
                    ),
              Text(
                data["type"],
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
