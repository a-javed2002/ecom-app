import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sixvalley_ecommerce/models/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sixvalley_ecommerce/features/vendors/saleOrders.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<MyMaterial> cart = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCartFromPrefs();
  }

  Future<void> loadCartFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartList = prefs.getStringList('cart');
    if (cartList != null) {
      setState(() {
        cart = cartList
            .map((item) => MyMaterial.fromJson(jsonDecode(item)))
            .toList();
      });
    }
  }

  Future<void> saveCartToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartList =
        cart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', cartList);
  }

  void updateQuantity(MyMaterial item, int quantity) {
    setState(() {
      item.quantity = quantity;
      if (item.quantity <= 0) {
        cart.remove(item);
      }
    });
    saveCartToPrefs();
    print("Updated cart: ${jsonEncode(cart.map((e) => e.toJson()).toList())}");
  }

  void removeItem(MyMaterial item) {
    setState(() {
      cart.remove(item);
    });
    saveCartToPrefs();
    print(
        "Cart after removal: ${jsonEncode(cart.map((e) => e.toJson()).toList())}");
  }

  double calculateTotalDiscount() {
    return cart.fold(0.0, (sum, item) => sum + item.discount * item.quantity);
  }

  double calculateGrandTotal() {
    return cart.fold(0.0, (sum, item) => sum + item.price * item.quantity) -
        calculateTotalDiscount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    final subTotal = item.price * item.quantity;
                    return Dismissible(
                      key: Key(item.material),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        removeItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${item.materialDesc} removed')));
                      },
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    'https://eshop.pakbev.com/public/storage/materials/${item.material}.png',
                                placeholder: (context, url) => Image.asset(
                                    'assets/images/placeholder.png'),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                        'assets/images/placeholder.png'),
                                width: 80,
                                height: 80,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.materialDesc,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      item.packSize,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                        'Price: ${item.price.toStringAsFixed(2)} Rs'),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            updateQuantity(
                                                item, item.quantity - 1);
                                          },
                                        ),
                                        Text('${item.quantity}'),
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            updateQuantity(
                                                item, item.quantity + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                        'Subtotal: ${subTotal.toStringAsFixed(2)} Rs'),
                                    if (item.discount > 0)
                                      Text(
                                        'Discount: -${item.discount.toStringAsFixed(2)} Rs',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total Discount: ${calculateTotalDiscount().toStringAsFixed(2)} Rs',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Grand Total: ${calculateGrandTotal().toStringAsFixed(2)} Rs',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          isLoading ? null : () => checkout(context, cart),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> checkout(BuildContext context, List<MyMaterial> cart) async {
    

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Your cart is empty. Add items to the cart before checking out.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? customerNumber = prefs.getString("customer_number");
    if (customerNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('First Login'),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    
    setState(() {
      isLoading = true;
    });

    const String apiUrl = 'https://eshop.pakbev.com/api/checkout';

    final List<Map<String, dynamic>> items = cart.map((item) {
      return {
        'MATERIAL': item.material,
        'quantity': item.quantity.toString(),
        'UNIT': item.unit.toString(),
        'ITEM_CATEG': 'TAN',
        'PRICE': item.price,
      };
    }).toList();

    final Map<String, dynamic> requestData = {
      'cart': items,
      'customer_number': customerNumber,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['Success']) {
          await prefs.remove('cart');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SaleOrdersScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Checkout failed: ${responseData['Data']}'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to checkout: ${response.reasonPhrase}'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during checkout: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
