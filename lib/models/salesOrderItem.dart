import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MySaleOrderItem {
  final String saleOrder;
  final String sno;
  final String material;
  final String materialDesc;
  final String materialGrp;
  final String materialGrpDesc;
  final String qty;
  final String totAmt;
  final String disc;
  final String netAmt;
  final String unit;
  final String foc;

  MySaleOrderItem({
    required this.saleOrder,
    required this.sno,
    required this.material,
    required this.materialDesc,
    required this.materialGrp,
    required this.materialGrpDesc,
    required this.qty,
    required this.totAmt,
    required this.disc,
    required this.netAmt,
    required this.unit,
    required this.foc,
  });

  factory MySaleOrderItem.fromJson(Map<String, dynamic> json) {
    return MySaleOrderItem(
      saleOrder: json['SALEORDER'],
      sno: json['SNO'],
      material: json['MATERIAL'],
      materialDesc: json['MATERIAL_DESC'],
      materialGrp: json['MATERIAL_GRP'],
      materialGrpDesc: json['MATERIAL_GRP_DESC'],
      qty: json['QTY'],
      totAmt: json['TOT_AMT'],
      disc: json['DISC'],
      netAmt: json['NET_AMT'],
      unit: json['UNIT'],
      foc: json['FOC'],
    );
  }
}

Future<List<MySaleOrderItem>?> fetchSaleOrderItems(
    BuildContext context, String saleOrderNumber) async {
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
  final response = await http.get(Uri.parse(
      'https://eshop.pakbev.com/api/saleOrderItems/$saleOrderNumber/$customerNumber'));
  print(response.statusCode);
  print(jsonDecode(response.body));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['d']['results'];
    return data.map((json) => MySaleOrderItem.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load sale order items');
  }
}
