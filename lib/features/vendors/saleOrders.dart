import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendors/saleOrderitems.dart';
import 'package:flutter_sixvalley_ecommerce/models/salesOrder.dart';

class SaleOrdersScreen extends StatefulWidget {
  @override
  _SaleOrdersScreenState createState() => _SaleOrdersScreenState();
}

class _SaleOrdersScreenState extends State<SaleOrdersScreen> {
  late Future<List<MySaleOrder>?> saleOrders;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    saleOrders = fetchSaleOrders(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: FutureBuilder<List<MySaleOrder>?>(
        future: saleOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sale orders found'));
          } else {
            final saleOrders = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: saleOrders.length,
              itemBuilder: (context, index) {
                final saleOrder = saleOrders[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    splashColor: Colors.blueAccent.withOpacity(0.3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleOrderItemsScreen(
                            saleOrderNumber: saleOrder.saleOrder,
                            order: saleOrder,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order: ${saleOrder.saleOrder}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Date & Time: ${saleOrder.orderDate} ${saleOrder.saleTime}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Quantity: ${saleOrder.qty}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Total Amount: ${saleOrder.totAmt}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Discount: ${saleOrder.disc}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Net Amount: ${saleOrder.netAmt}',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
