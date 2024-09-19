import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendors/cart.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendors/saleOrders.dart';
import 'package:flutter_sixvalley_ecommerce/models/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MaterialsScreen extends StatefulWidget {
  @override
  _MaterialsScreenState createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  List<MyMaterial> materials = [];
  List<Category> categories = [];
  List<SubCategory> subCategories = [];

  String? selectedCategory;
  String? selectedSubCategory;

  List<MyMaterial> cart = [];
  int cartCount = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMaterialsData();
  }

  Future<void> fetchMaterialsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await fetchMaterials();
      setState(() {
        materials = data['materials'];
        categories = data['categories'];
        subCategories = data['subCategories'];
        isLoading = false;
      });

      if (categories.isNotEmpty) {
        selectedCategory = categories.first.id;
        selectedSubCategory = subCategories
            .where((sub) => sub.category == selectedCategory)
            .isNotEmpty
            ? subCategories.firstWhere((sub) => sub.category == selectedCategory).id
            : null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Loaded ${categories.length} categories, ${subCategories.length} sub-categories, and ${materials.length} materials.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load materials: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void addToCart(MyMaterial material) async {
    bool alreadyInCart = cart.any((item) => item.material == material.material);

    if (alreadyInCart) {
      setState(() {
        MyMaterial existingMaterial =
            cart.firstWhere((item) => item.material == material.material);
        existingMaterial.quantity++;
      });
    } else {
      setState(() {
        cart.add(material);
      });
      cartCount = cart.fold(0, (sum, item) => sum + item.quantity);
    }

    saveCartToPrefs();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${material.materialDesc} added to cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void saveCartToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartList =
        cart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', cartList);
  }

  List<MyMaterial> getFilteredMaterials() {
    return materials.where((mat) {
      return mat.category == selectedCategory &&
          (selectedSubCategory == null || mat.materialGrp == selectedSubCategory);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SaleOrdersScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 7,
                top: 7,
                child: cartCount > 0
                    ? Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$cartCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text('Categories',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Container(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            String imageUrl =
                                'https://eshop.pakbev.com/storage/app/public/static/category/image-${category.id}.png';
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category.id;
                                  selectedSubCategory = subCategories
                                          .where((sub) =>
                                              sub.category == selectedCategory)
                                          .isNotEmpty
                                      ? subCategories
                                          .firstWhere((sub) =>
                                              sub.category == selectedCategory)
                                          .id
                                      : null;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(8),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      CachedNetworkImageProvider(imageUrl),
                                  backgroundColor: category.id == selectedCategory
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (selectedCategory != null) ...[
                        Text('Sub-Categories',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Container(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: subCategories
                                .where((sub) => sub.category == selectedCategory)
                                .length,
                            itemBuilder: (context, index) {
                              final subCategory = subCategories
                                  .where((sub) => sub.category == selectedCategory)
                                  .toList()[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSubCategory = subCategory.id;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: subCategory.id == selectedSubCategory
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(subCategory.materialGrpDesc,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Text('Products',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final filteredMaterials = getFilteredMaterials();
                      final material = filteredMaterials[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://eshop.pakbev.com/public/storage/materials/${material.material}.png',
                                placeholder: (context, url) =>
                                    Image.asset('assets/images/placeholder.png'),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/placeholder.png'),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                material.materialDesc,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                material.packSize,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${material.price.toStringAsFixed(2)} Rs'),
                                  IconButton(
                                    icon: Icon(Icons.add_shopping_cart),
                                    onPressed: () => addToCart(material),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: getFilteredMaterials().length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                ),
              ],
            ),
    );
  }
}
