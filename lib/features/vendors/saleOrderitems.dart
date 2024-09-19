import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/models/salesOrder.dart';
import 'package:flutter_sixvalley_ecommerce/models/salesOrderItem.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaleOrderItemsScreen extends StatefulWidget {
  final String saleOrderNumber;
  final MySaleOrder order;

  SaleOrderItemsScreen({required this.saleOrderNumber, required this.order});

  @override
  _SaleOrderItemsScreenState createState() => _SaleOrderItemsScreenState();
}

class _SaleOrderItemsScreenState extends State<SaleOrderItemsScreen> {
  late Future<List<MySaleOrderItem>?> saleOrderItems;

  @override
  void initState() {
    super.initState();
    saleOrderItems = fetchSaleOrderItems(context, widget.saleOrderNumber);
  }

  Future<void> _generatePdfAndShare(List<MySaleOrderItem> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Order: ${widget.order.saleOrder}'),
            pw.Text('Date & Time: ${widget.order.orderDate} ${widget.order.saleTime}'),
            pw.Text('Total Amount: ${widget.order.totAmt}'),
            pw.Text('Discount: ${widget.order.disc}'),
            pw.Text('Net Amount: ${widget.order.netAmt}'),
            pw.Divider(),
            pw.Text('Items', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ...items.map((item) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Material: ${item.materialDesc}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Quantity: ${item.qty} ${item.unit}'),
                pw.Text('Total Amount: ${item.totAmt}'),
                pw.Text('Discount: ${item.disc}'),
                pw.Text('Net Amount: ${item.netAmt}'),
                pw.Divider(),
              ],
            )),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoice_${widget.order.saleOrder}.pdf');
    await file.writeAsBytes(await pdf.save());

    Share.shareFiles([file.path], text: 'Invoice for order ${widget.order.saleOrder}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          FutureBuilder<List<MySaleOrderItem>?>(
            future: saleOrderItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () => _generatePdfAndShare(snapshot.data!),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MySaleOrderItem>?>(
        future: saleOrderItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sale order items found'));
          } else {
            final items = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order: ${widget.order.saleOrder}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('Date & Time: ${widget.order.orderDate} ${widget.order.saleTime}'),
                          Text('Total Amount: ${widget.order.totAmt}'),
                          Text('Discount: ${widget.order.disc}'),
                          Text('Net Amount: ${widget.order.netAmt}'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final saleOrderItem = items[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Material: ${saleOrderItem.materialDesc}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              Divider(color: Colors.grey),
                              Text('Material Group: ${saleOrderItem.materialGrpDesc}'),
                              Text('Quantity: ${saleOrderItem.qty} ${saleOrderItem.unit}'),
                              Text('Total Amount: ${saleOrderItem.totAmt}'),
                              Text('Discount: ${saleOrderItem.disc}'),
                              Text('Net Amount: ${saleOrderItem.netAmt}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
