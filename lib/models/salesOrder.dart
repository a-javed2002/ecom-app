import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySaleOrder {
  final String id;
  final String uri;
  final String type;
  final String customer;
  final String saleOrder;
  final String saleTime;
  final String orderDate;
  final String qty;
  final String totAmt;
  final String disc;
  final String netAmt;
  final String delvStatus;
  final String payStatus;

  MySaleOrder({
    required this.id,
    required this.uri,
    required this.type,
    required this.customer,
    required this.saleOrder,
    required this.saleTime,
    required this.orderDate,
    required this.qty,
    required this.totAmt,
    required this.disc,
    required this.netAmt,
    required this.delvStatus,
    required this.payStatus,
  });

  factory MySaleOrder.fromJson(Map<String, dynamic> json) {
    return MySaleOrder(
      id: json['__metadata']['id'],
      uri: json['__metadata']['uri'],
      type: json['__metadata']['type'],
      customer: json['CUSTOMER'],
      saleOrder: json['SALEORDER'],
      orderDate: json['ORDER_DATE'],
      saleTime: json['ORDER_TIME'],
      qty: json['QTY'],
      totAmt: json['TOT_AMT'],
      disc: json['DISC'],
      netAmt: json['NET_AMT'],
      delvStatus: json['DELV_STATUS'],
      payStatus: json['PAY_STATUS'],
    );
  }
}

Future<List<MySaleOrder>?> fetchSaleOrders(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? customerNumber = prefs.getString("customer_number");
  if (customerNumber == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('First Login'),
      ),
    );
    return null;
  }
  final response = await http.get(
      Uri.parse('https://eshop.pakbev.com/api/saleOrders/$customerNumber'));
  print(response.statusCode);
  print(jsonDecode(response.body));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['d']['results'];
    return data.map((json) => MySaleOrder.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load sale orders');
  }
}
