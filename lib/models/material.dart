import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyMaterial {
  final String customer;
  final String material;
  final String materialDesc;
  final String materialGrp;
  final String materialGrpDesc;
  final String category;
  final String categoryDesc;
  double price;
  double discount;
  final String unit;
  final String packSize;
  int quantity;

  MyMaterial({
    required this.customer,
    required this.material,
    required this.materialDesc,
    required this.materialGrp,
    required this.materialGrpDesc,
    required this.category,
    required this.categoryDesc,
    required this.price,
    required this.discount,
    required this.unit,
    required this.packSize,
    this.quantity = 1,
  });

  factory MyMaterial.fromJson(Map<String, dynamic> json) {
    return MyMaterial(
      customer: json['CUSTOMER'],
      material: json['MATERIAL'],
      materialDesc: json['MATERIAL_DESC'],
      materialGrp: json['MATERIAL_GRP'],
      materialGrpDesc: json['MATERIAL_GRP_DESC'],
      category: json['CATEGORY'],
      categoryDesc: json['CATEGORY_DESC'],
      price: double.tryParse(json['PRICE'].toString().trim()) ?? 0,
      discount: double.tryParse(json['DISCOUNT'].toString().trim()) ?? 0,
      unit: json['UNIT'],
      packSize: json['PACK_SIZE'],
      quantity: json['QUANTITY'] ?? 1, // Ensure quantity is set
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CUSTOMER': customer,
      'MATERIAL': material,
      'MATERIAL_DESC': materialDesc,
      'MATERIAL_GRP': materialGrp,
      'MATERIAL_GRP_DESC': materialGrpDesc,
      'CATEGORY': category,
      'CATEGORY_DESC': categoryDesc,
      'PRICE': price,
      'DISCOUNT': discount,
      'UNIT': unit,
      'PACK_SIZE': packSize,
      'QUANTITY': quantity, // Include quantity in serialization
    };
  }
}

class Category {
  final String id;
  final String description;

  Category({required this.id, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json.keys.first,
      description: json.values.first,
    );
  }
}

class SubCategory {
  final String id;
  final String materialGrpDesc;
  final String category;

  SubCategory({
    required this.id,
    required this.materialGrpDesc,
    required this.category,
  });

  factory SubCategory.fromJson(String id, Map<String, dynamic> json) {
    return SubCategory(
      id: id,
      materialGrpDesc: json['MATERIAL_GRP_DESC'],
      category: json['CATEGORY'],
    );
  }
}

Future<Map<String, dynamic>> fetchMaterials() async {
  final prefs = await SharedPreferences.getInstance();
  String? customerNumber = prefs.getString("customer_number");
  if (customerNumber == null) {
    customerNumber = '';
  }
  final url =
      Uri.parse('https://eshop.pakbev.com/api/materials/$customerNumber');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> materialsData = jsonResponse['materials'];
    final Map<String, dynamic> categoriesData = jsonResponse['categories'];
    final Map<String, dynamic> subCategoriesData =
        jsonResponse['subCategories'];

    List<MyMaterial> materials =
        materialsData.map((json) => MyMaterial.fromJson(json)).toList();
    List<Category> categories = categoriesData.entries
        .map((entry) => Category(id: entry.key, description: entry.value))
        .toList();
    List<SubCategory> subCategories = subCategoriesData.entries
        .map((entry) => SubCategory.fromJson(entry.key, entry.value))
        .toList();

    return {
      'materials': materials,
      'categories': categories,
      'subCategories': subCategories,
    };
  } else {
    throw Exception('Failed to load materials');
  }
}
