import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/screens/view_all_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/featured_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/products_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/models/customer.dart';
import 'package:flutter_sixvalley_ecommerce/models/material.dart';
import 'package:flutter_sixvalley_ecommerce/models/salesOrder.dart';
import 'package:flutter_sixvalley_ecommerce/models/salesOrderItem.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/screens/featured_deal_screen_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/featured_product_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/order_again_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/top_store_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/announcement_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/more_store_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/order_again_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/cart_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/featured_deal_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/single_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/just_for_you/just_for_you_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/widgets/more_store_list_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/screens/flash_deal_screen_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/widgets/top_seller_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/all_shop_screen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sixvalley_ecommerce/features/vendors/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendors/cart.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendors/saleOrders.dart';
import 'package:flutter_sixvalley_ecommerce/models/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AsterThemeHomeScreen extends StatefulWidget {
  const AsterThemeHomeScreen({super.key});

  @override
  State<AsterThemeHomeScreen> createState() => _AsterThemeHomeScreenState();
}

class _AsterThemeHomeScreenState extends State<AsterThemeHomeScreen>
    with SingleTickerProviderStateMixin {
  List<MyMaterial> materials = [];
  List<MyMaterial> discountedMaterials = [];
  List<Category> categories = [];
  List<SubCategory> subCategories = [];

  String? selectedCategory;
  String? selectedSubCategory;

  List<MyMaterial> cart = [];
  int cartCount = 0;

  late AnimationController _animationController;
  late Animation<Offset> _animation;
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadData(bool reload) async {
    await Provider.of<BannerController>(Get.context!, listen: false)
        .getBannerList(reload);
    // await Provider.of<CategoryController>(Get.context!, listen: false)
    //     .getCategoryList(reload);
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .getHomeCategoryProductList(reload);
    // await Provider.of<ShopController>(Get.context!, listen: false)
    //     .getTopSellerList(reload, 1, type: "top");
    // await Provider.of<BrandController>(Get.context!, listen: false)
    //     .getBrandList(reload);
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .getLatestProductList(1, reload: reload);
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .getFeaturedProductList('1', reload: reload);
    // await Provider.of<FeaturedDealController>(Get.context!, listen: false)
    //     .getFeaturedDealList(reload);
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .getLProductList('1', reload: reload);
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .getRecommendedProduct();
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .findWhatYouNeed();
    // await Provider.of<ProductController>(Get.context!, listen: false)
    //     .getJustForYouProduct();
    // await Provider.of<ShopController>(Get.context!, listen: false)
    //     .getMoreStore();
    // await Provider.of<NotificationController>(Get.context!, listen: false)
    //     .getNotificationList(1);
    if (Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()) {
      await Provider.of<ProfileController>(Get.context!, listen: false)
          .getUserInfo(Get.context!);
      // await Provider.of<SellerProductController>(Get.context!, listen: false)
      //     .getShopAgainFromRecentStore();
      // await Provider.of<OrderController>(Get.context!, listen: false)
      //     .getOrderList(1, 'delivered', type: 'reorder');
      // await Provider.of<WishListController>(Get.context!, listen: false)
      //     .getWishList();
    }
    // fetchMaterialsData();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  // Future<void> fetchMaterialsData() async {
  //   try {
  //     final data = await fetchMaterials();
  //     setState(() {
  //       materials = data['materials'];
  //       discountedMaterials =
  //           materials.where((material) => material.discount > 0).toList();
  //       categories = data['categories'];
  //       subCategories = data['subCategories'];
  //     });

  //     if (categories.isNotEmpty) {
  //       selectedCategory = categories.first.id;
  //       if (subCategories
  //           .where((sub) => sub.category == selectedCategory)
  //           .isNotEmpty) {
  //         selectedSubCategory = subCategories
  //             .firstWhere((sub) => sub.category == selectedCategory)
  //             .id;
  //       }
  //     }

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //             'Loaded ${categories.length} categories, ${subCategories.length} sub-categories, and ${materials.length} materials.'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   } catch (e) {
  //     print(e);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to load materials: $e'),
  //         duration: Duration(seconds: 13),
  //       ),
  //     );
  //   }
  // }

  void addToCart(MyMaterial material) async {
    bool alreadyInCart = cart.any((item) => item.material == material.material);

    if (alreadyInCart) {
      setState(() {
        cart
            .firstWhere((item) => item.material == material.material)
            .quantity++;
      });
    } else {
      setState(() {
        cart.add(material);
      });
    }

    setState(() {
      cartCount++;
    });

    saveCartToPrefs();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${material.materialDesc} added to cart'),
        duration: Duration(seconds: 2),
      ),
    );

    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void saveCartToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartList =
        cart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', cartList);
  }

  void passData(int index, String title) {
    index = index;
    title = title;
  }

  bool singleVendor = false;
  @override
  void initState() {
    super.initState();

    // singleVendor = Provider.of<SplashController>(context, listen: false)
    //         .configModel!
    //         .businessMode ==
    //     "single";
    // Provider.of<FlashDealController>(context, listen: false)
    //     .getFlashDealList(true, true);

    _loadData(false);

    // Provider.of<CartController>(context, listen: false).getCartData(context);
  }

  @override
  Widget build(BuildContext context) {
    List<String?> types = [
      getTranslated('new_arrival', context),
      getTranslated('top_product', context),
      getTranslated('best_selling', context),
      getTranslated('discounted_product', context)
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadData(true);
            // await Provider.of<FlashDealController>(Get.context!, listen: false)
            //     .getFlashDealList(true, false);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                elevation: 0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).highlightColor,
                title: Image.asset(Images.logoWithNameImage, height: 35),
                // actions: const [CartHomePageWidget()]),
                // actions: const [CartHomePageWidget()]
                actions: [
                  // IconButton(
                  //   icon: const Icon(Icons.refresh),
                  //   onPressed: () {
                  //     fetchMaterialsData();
                  //   },
                  // ),

                  // IconButton(
                  //   icon: const Icon(Icons.home),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => MaterialsScreen()),
                  //     );
                  //   },
                  // ),
                  IconButton(
                    icon: const Icon(Icons.receipt),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SaleOrdersScreen()),
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
                            MaterialPageRoute(
                                builder: (context) => CartScreen()),
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

              // SliverToBoxAdapter(
              //   child: Provider.of<SplashController>(context, listen: false)
              //               .configModel!
              //               .announcement!
              //               .status ==
              //           '1'
              //       ? Consumer<SplashController>(
              //           builder: (context, announcement, _) {
              //             return (announcement.configModel!.announcement!
              //                             .announcement !=
              //                         null &&
              //                     announcement.onOff)
              //                 ? AnnouncementWidget(
              //                     announcement:
              //                         announcement.configModel!.announcement)
              //                 : const SizedBox();
              //           },
              //         )
              //       : const SizedBox(),
              // ),

              // const SizedBox(height: 20,),

              // Search Button
              // SliverPersistentHeader(
              //     pinned: true,
              //     delegate: SliverDelegate(
              //         child: InkWell(
              //             onTap: () => Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                     builder: (_) => const SearchScreen())),
              //             child: const SearchHomePageWidget()))),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BannersWidget(),
                    const SizedBox(height: Dimensions.homePagePadding),

// Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('All Products',
//                               style: TextStyle(
//                                   fontSize: 24, fontWeight: FontWeight.bold)),
//                           SizedBox(height: 10),
//                           Expanded(
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: materials.length,
//                               itemBuilder: (context, index) {
//                                 final material = materials[index];
//                                 return Card(
//                                   margin: EdgeInsets.all(8),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: CachedNetworkImage(
//                                           imageUrl:
//                                               'https://eshop.pakbev.com/storage/app/public/materials/${material.material}.png',
//                                           placeholder: (context, url) =>
//                                               Image.asset(
//                                                   'assets/images/placeholder.png'),
//                                           errorWidget: (context, url, error) =>
//                                               Image.asset(
//                                                   'assets/images/placeholder.png'),
//                                           fit: BoxFit.cover,
//                                           width: 150,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           material.materialDesc,
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.bold),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                                 '\$${material.price.toStringAsFixed(2)}'),
//                                             IconButton(
//                                               icon:
//                                                   Icon(Icons.add_shopping_cart),
//                                               onPressed: () =>
//                                                   addToCart(material),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Discounted Products', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: discountedMaterials.length,
//                 itemBuilder: (context, index) {
//                   final material = discountedMaterials[index];
//                   final discountedPrice = material.price - material.discount;
//                   return Card(
//                     margin: EdgeInsets.all(8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: CachedNetworkImage(
//                             imageUrl: 'https://eshop.pakbev.com/storage/app/public/materials/${material.material}.png',
//                             placeholder: (context, url) => Image.asset('assets/images/placeholder.png'),
//                             errorWidget: (context, url, error) => Image.asset('assets/images/placeholder.png'),
//                             fit: BoxFit.cover,
//                             width: 150,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             material.materialDesc,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '\$${material.price.toStringAsFixed(2)}',
//                                     style: TextStyle(
//                                       decoration: TextDecoration.lineThrough,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                   Text(
//                                     '\$${discountedPrice.toStringAsFixed(2)}',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.add_shopping_cart),
//                                 onPressed: () => addToCart(material),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.green,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          print("fetch cust");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MaterialsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(double.infinity, 150),
                        ),
                        child: Text(
                          "See Products",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white, // Ensure text is visible
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.homePagePadding),

                    // ElevatedButton(
                    //     onPressed: () {
                    //       print("Material");
                    //       fetchMaterials();
                    //     },
                    //     child: Text("Material")),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       print("Sale Order Items");
                    //       fetchSaleOrders();
                    //     },
                    //     child: Text("Sale Order")),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       print("Sale Order Items");
                    //       fetchSaleOrderItems();
                    //     },
                    //     child: Text("Sale Order Items")),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       print("Check Out");
                    //       checkout();
                    //     },
                    //     child: Text("Check Out")),

                    //               Column(
                    //   children: [
                    //     Text('Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    //     Container(
                    //       height: 80,
                    //       child: ListView.builder(
                    //         scrollDirection: Axis.horizontal,
                    //         itemCount: categories.length,
                    //         itemBuilder: (context, index) {
                    //           final category = categories[index];
                    //           return GestureDetector(
                    //             onTap: () {
                    //               setState(() {
                    //                 selectedCategory = category.id;
                    //                 selectedSubCategory = subCategories.where((sub) => sub.category == selectedCategory).isNotEmpty
                    //                     ? subCategories.firstWhere((sub) => sub.category == selectedCategory).id
                    //                     : null;
                    //               });
                    //             },
                    //             child: Container(
                    //               margin: EdgeInsets.all(8),
                    //               padding: EdgeInsets.all(16),
                    //               decoration: BoxDecoration(
                    //                 color: category.id == selectedCategory ? Colors.blue : Colors.grey,
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //               child: Center(
                    //                 child: Text(category.description, style: TextStyle(color: Colors.white)),
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //     if (selectedCategory != null) ...[
                    //       Text('Sub-Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    //       Container(
                    //         height: 80,
                    //         child: ListView.builder(
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: subCategories.where((sub) => sub.category == selectedCategory).length,
                    //           itemBuilder: (context, index) {
                    //             final subCategory = subCategories.where((sub) => sub.category == selectedCategory).toList()[index];
                    //             return GestureDetector(
                    //               onTap: () {
                    //                 setState(() {
                    //                   selectedSubCategory = subCategory.id;
                    //                 });
                    //               },
                    //               child: Container(
                    //                 margin: EdgeInsets.all(8),
                    //                 padding: EdgeInsets.all(16),
                    //                 decoration: BoxDecoration(
                    //                   color: subCategory.id == selectedSubCategory ? Colors.blue : Colors.grey,
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //                 child: Center(
                    //                   child: Text(subCategory.materialGrpDesc, style: TextStyle(color: Colors.white)),
                    //                 ),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //     if (selectedSubCategory != null) ...[
                    //       Text('Materials', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    //       Expanded(
                    //         child: GridView.builder(
                    //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //             crossAxisCount: 2,
                    //             childAspectRatio: 2 / 3,
                    //           ),
                    //           itemCount: materials.where((mat) => mat.materialGrp == selectedSubCategory).length,
                    //           itemBuilder: (context, index) {
                    //             final material = materials.where((mat) => mat.materialGrp == selectedSubCategory).toList()[index];
                    //             return Card(
                    //               margin: EdgeInsets.all(8),
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Expanded(
                    //                     child: CachedNetworkImage(
                    //                       imageUrl: 'assets/materials/${material.material}.png',
                    //                       placeholder: (context, url) => Image.asset('assets/images/placeholder.png'),
                    //                       errorWidget: (context, url, error) => Image.asset('assets/images/placeholder.png'),
                    //                       fit: BoxFit.cover,
                    //                       width: double.infinity,
                    //                     ),
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.all(8.0),
                    //                     child: Text(
                    //                       material.materialDesc,
                    //                       style: TextStyle(fontWeight: FontWeight.bold),
                    //                       maxLines: 2,
                    //                       overflow: TextOverflow.ellipsis,
                    //                     ),
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //                     child: Text('Price: ${material.price}'),
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //                     child: Text('Pack Size: ${material.packSize}'),
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //                     child: Text('Unit: ${material.unit}'),
                    //                   ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.all(8.0),
                    //                     child: ElevatedButton(
                    //                       onPressed: () {
                    //                         addToCart(material);
                    //                       },
                    //                       child: Text('Add to Cart'),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ],
                    // ),

                    // Consumer<FlashDealController>(
                    //     builder: (context, megaDeal, child) {
                    //   return megaDeal.flashDeal != null
                    //       ? megaDeal.flashDealList.isNotEmpty
                    //           ? Column(children: [
                    //               Padding(
                    //                 padding: const EdgeInsets.fromLTRB(
                    //                     Dimensions.homePagePadding,
                    //                     Dimensions.paddingSizeSmall,
                    //                     Dimensions.paddingSizeDefault,
                    //                     Dimensions.paddingSizeExtraExtraSmall),
                    //                 child: TitleRowWidget(
                    //                     title: getTranslated(
                    //                         'flash_deal', context),
                    //                     eventDuration:
                    //                         megaDeal.flashDeal != null
                    //                             ? megaDeal.duration
                    //                             : null,
                    //                     onTap: () {
                    //                       Navigator.push(
                    //                           context,
                    //                           MaterialPageRoute(
                    //                               builder: (_) =>
                    //                                   const FlashDealScreenView()));
                    //                     },
                    //                     isFlash: true),
                    //               ),
                    //               const SizedBox(
                    //                   height: Dimensions.paddingSizeSmall),
                    //               Text(
                    //                   getTranslated(
                    //                           'hurry_up_the_offer_is_limited_grab_while_it_lasts',
                    //                           context) ??
                    //                       '',
                    //                   style: textRegular.copyWith(
                    //                       color: Provider.of<ThemeController>(
                    //                                   context,
                    //                                   listen: false)
                    //                               .darkTheme
                    //                           ? Theme.of(context).hintColor
                    //                           : Theme.of(context).primaryColor,
                    //                       fontSize:
                    //                           Dimensions.fontSizeDefault)),
                    //               const SizedBox(
                    //                   height: Dimensions.paddingSizeDefault),
                    //               SizedBox(
                    //                   height: ResponsiveHelper.isTab(context)
                    //                       ? MediaQuery.of(context).size.width *
                    //                           .58
                    //                       : 350,
                    //                   child: const Padding(
                    //                       padding: EdgeInsets.only(
                    //                           bottom:
                    //                               Dimensions.homePagePadding),
                    //                       child: FlashDealsListWidget()))
                    //             ])
                    //           : const SizedBox.shrink()
                    //       : const FlashDealShimmer();
                    // }),

                    // Find what you need
                    // Consumer<ProductController>(
                    //     builder: (context, productController, _) {
                    //   return productController.findWhatYouNeedModel != null
                    //       ? (productController.findWhatYouNeedModel!
                    //                       .findWhatYouNeed !=
                    //                   null &&
                    //               productController.findWhatYouNeedModel!
                    //                   .findWhatYouNeed!.isNotEmpty)
                    //           ? Padding(
                    //               padding: const EdgeInsets.only(
                    //                   bottom: Dimensions.homePagePadding,
                    //                   top: Dimensions.homePagePadding),
                    //               child: Column(children: [
                    //                 TitleRowWidget(
                    //                     title: getTranslated(
                    //                         'find_what_you_need', context)),
                    //                 const SizedBox(
                    //                     height: Dimensions.homePagePadding),
                    //                 SizedBox(
                    //                     height: ResponsiveHelper.isTab(context)
                    //                         ? 165
                    //                         : 150,
                    //                     child: const FindWhatYouNeedView()),
                    //               ]))
                    //           : const SizedBox()
                    //       : const FindWhatYouNeedShimmer();
                    // }),

                    //Order Again
                    // (Provider.of<AuthController>(context, listen: false)
                    //         .isLoggedIn())
                    //     ? Consumer<OrderController>(
                    //         builder: (context, orderProvider, _) {
                    //         return orderProvider.deliveredOrderModel != null
                    //             ? (orderProvider.deliveredOrderModel!.orders !=
                    //                         null &&
                    //                     orderProvider.deliveredOrderModel!
                    //                         .orders!.isNotEmpty)
                    //                 ? const Padding(
                    //                     padding: EdgeInsets.all(
                    //                         Dimensions.homePagePadding),
                    //                     child: OrderAgainView(),
                    //                   )
                    //                 : Consumer<BannerController>(builder:
                    //                     (context, bannerProvider, child) {
                    //                     return bannerProvider.sideBarBanner !=
                    //                             null
                    //                         ? Padding(
                    //                             padding: const EdgeInsets.only(
                    //                                 bottom: Dimensions
                    //                                     .homePagePadding,
                    //                                 left: Dimensions
                    //                                     .bannerPadding,
                    //                                 right: Dimensions
                    //                                     .bannerPadding),
                    //                             child: SingleBannersWidget(
                    //                                 bannerModel: bannerProvider
                    //                                     .sideBarBanner,
                    //                                 height:
                    //                                     MediaQuery.of(context)
                    //                                             .size
                    //                                             .width *
                    //                                         1.2))
                    //                         : const SizedBox();
                    //                   })
                    //             : const OrderAgainShimmerShimmer();
                    //       })
                    //     : Consumer<BannerController>(
                    //         builder: (context, bannerProvider, child) {
                    //         return bannerProvider.sideBarBanner != null
                    //             ? Padding(
                    //                 padding: const EdgeInsets.only(
                    //                     bottom: Dimensions.homePagePadding,
                    //                     left: Dimensions.bannerPadding,
                    //                     right: Dimensions.bannerPadding),
                    //                 child: SingleBannersWidget(
                    //                     bannerModel:
                    //                         bannerProvider.sideBarBanner,
                    //                     height:
                    //                         MediaQuery.of(context).size.width *
                    //                             1.2))
                    //             : const SizedBox();
                    //       }),
                    // const SizedBox(
                    //   height: Dimensions.paddingSizeDefault,
                    // ),

                    //top seller
                    // singleVendor
                    //     ? const SizedBox()
                    //     : Consumer<ShopController>(
                    //         builder: (context, shopController, _) {
                    //         return shopController.sellerModel != null
                    //             ? (shopController.sellerModel!.sellers !=
                    //                         null &&
                    //                     shopController
                    //                         .sellerModel!.sellers!.isNotEmpty)
                    //                 ? Column(children: [
                    //                     TitleRowWidget(
                    //                         title: getTranslated(
                    //                             'top_stores', context),
                    //                         onTap: () => Navigator.push(
                    //                             context,
                    //                             MaterialPageRoute(
                    //                                 builder: (_) =>
                    //                                     const AllTopSellerScreen(
                    //                                       title: 'top_stores',
                    //                                     )))),
                    //                     const SizedBox(
                    //                         height:
                    //                             Dimensions.paddingSizeSmall),
                    //                     Padding(
                    //                         padding: const EdgeInsets.only(
                    //                             bottom:
                    //                                 Dimensions.homePagePadding),
                    //                         child: SizedBox(
                    //                             height: ResponsiveHelper.isTab(
                    //                                     context)
                    //                                 ? 180
                    //                                 : 165,
                    //                             child: TopSellerView(
                    //                               isHomePage: true,
                    //                               scrollController:
                    //                                   _scrollController,
                    //                             ))),
                    //                   ])
                    //                 : const SizedBox()
                    //             : const TopStoreShimmer();
                    //       }),

                    // Consumer<FeaturedDealController>(
                    //   builder: (context, featuredDealProvider, child) {
                    //     return featuredDealProvider.featuredDealProductList !=
                    //             null
                    //         ? featuredDealProvider
                    //                 .featuredDealProductList!.isNotEmpty
                    //             ? Stack(children: [
                    //                 Container(
                    //                     width:
                    //                         MediaQuery.of(context).size.width,
                    //                     height: 150,
                    //                     color: Provider.of<ThemeController>(
                    //                                 context,
                    //                                 listen: false)
                    //                             .darkTheme
                    //                         ? Theme.of(context)
                    //                             .primaryColor
                    //                             .withOpacity(.20)
                    //                         : Theme.of(context)
                    //                             .primaryColor
                    //                             .withOpacity(.125)),
                    //                 Padding(
                    //                     padding: const EdgeInsets.only(
                    //                         bottom: Dimensions.homePagePadding),
                    //                     child: Column(children: [
                    //                       Padding(
                    //                           padding:
                    //                               const EdgeInsets.fromLTRB(
                    //                                   0,
                    //                                   Dimensions
                    //                                       .paddingSizeDefault,
                    //                                   0,
                    //                                   Dimensions
                    //                                       .paddingSizeDefault),
                    //                           child: TitleRowWidget(
                    //                               title:
                    //                                   '${getTranslated('featured_deals', context)}',
                    //                               onTap: () => Navigator.push(
                    //                                   context,
                    //                                   MaterialPageRoute(
                    //                                       builder: (_) =>
                    //                                           const FeaturedDealScreenView())))),
                    //                       const FeaturedDealsListWidget()
                    //                     ]))
                    //               ])
                    //             : const SizedBox.shrink()
                    //         : const FindWhatYouNeedShimmer();
                    //   },
                    // ),

                    Consumer<BannerController>(
                        builder: (context, footerBannerProvider, child) {
                      return footerBannerProvider.footerBannerList != null &&
                              footerBannerProvider.footerBannerList!.length > 1
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.homePagePadding,
                                  left: Dimensions.homePagePadding,
                                  right: Dimensions.homePagePadding),
                              child: SingleBannersWidget(
                                bannerModel:
                                    footerBannerProvider.footerBannerList?[1],
                              ))
                          : const SizedBox();
                    }),

                    // Consumer<ProductController>(
                    //     builder: (context, featured, _) {
                    //   return featured.featuredProductList != null
                    //       ? featured.featuredProductList!.isNotEmpty
                    //           ? Stack(children: [
                    //               Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 50, bottom: 25),
                    //                   child: Container(
                    //                       width: MediaQuery.of(context)
                    //                               .size
                    //                               .width -
                    //                           50,
                    //                       height:
                    //                           Dimensions.featuredProductCard,
                    //                       decoration: BoxDecoration(
                    //                           borderRadius: const BorderRadius.only(
                    //                               topLeft: Radius.circular(
                    //                                   Dimensions
                    //                                       .paddingSizeDefault),
                    //                               bottomLeft: Radius.circular(
                    //                                   Dimensions
                    //                                       .paddingSizeDefault)),
                    //                           color: Theme.of(context)
                    //                               .colorScheme
                    //                               .onSecondaryContainer))),
                    //               Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     TitleRowWidget(
                    //                         title: getTranslated(
                    //                             'featured_products', context),
                    //                         onTap: () => Navigator.push(
                    //                             context,
                    //                             MaterialPageRoute(
                    //                                 builder: (_) => AllProductScreen(
                    //                                     productType: ProductType
                    //                                         .featuredProduct)))),
                    //                     Padding(
                    //                         padding: const EdgeInsets.only(
                    //                             bottom:
                    //                                 Dimensions.homePagePadding),
                    //                         child: FeaturedProductWidget(
                    //                             scrollController:
                    //                                 _scrollController,
                    //                             isHome: true))
                    //                   ])
                    //             ])
                    //           : const SizedBox()
                    //       : const FeaturedProductShimmer();
                    // }),

                    Consumer<BannerController>(
                        builder: (context, bannerProvider, child) {
                      return bannerProvider.topSideBarBannerBottom != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.homePagePadding,
                                  left: Dimensions.bannerPadding,
                                  right: Dimensions.bannerPadding),
                              child: SingleBannersWidget(
                                  bannerModel:
                                      bannerProvider.topSideBarBannerBottom,
                                  height:
                                      MediaQuery.of(context).size.width * 1.2))
                          : const SizedBox();
                    }),

                    // const Padding(
                    //     padding:
                    //         EdgeInsets.only(bottom: Dimensions.homePagePadding),
                    //     child: RecommendedProductWidget(fromAsterTheme: true)),

                    // const LatestProductListWidget(),
                    // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    //blackFriday
                    Consumer<BannerController>(
                        builder: (context, bannerProvider, child) {
                      return bannerProvider.footerBannerList != null &&
                              bannerProvider.footerBannerList!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.homePagePadding,
                                  left: Dimensions.homePagePadding,
                                  right: Dimensions.homePagePadding),
                              child: SingleBannersWidget(
                                  bannerModel:
                                      bannerProvider.footerBannerList![0],
                                  height:
                                      MediaQuery.of(context).size.width * 0.5))
                          : const SizedBox();
                    }),

                    // SizedBox(child: Consumer<ProductController>(
                    //     builder: (context, productController, _) {
                    //   return (productController.justForYouProduct != null &&
                    //           productController.justForYouProduct!.isNotEmpty)
                    //       ? Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //               TitleRowWidget(
                    //                 title:
                    //                     getTranslated('just_for_you', context),
                    //                 onTap: () {
                    //                   Navigator.push(
                    //                       context,
                    //                       MaterialPageRoute(
                    //                           builder: (_) => AllProductScreen(
                    //                               productType:
                    //                                   ProductType.justForYou)));
                    //                 },
                    //               ),
                    //               JustForYouView(
                    //                   productList:
                    //                       productController.justForYouProduct)
                    //             ])
                    //       : const SizedBox();
                    // })),

                    // Consumer<ShopController>(
                    //     builder: (context, moreStoreProvider, _) {
                    //   return moreStoreProvider.moreStoreList.isNotEmpty
                    //       ? Padding(
                    //           padding: const EdgeInsets.fromLTRB(
                    //             0,
                    //             Dimensions.paddingSizeSmall,
                    //             0,
                    //             Dimensions.paddingSizeSmall,
                    //           ),
                    //           child: Column(children: [
                    //             TitleRowWidget(
                    //                 title: getTranslated('more_store', context),
                    //                 onTap: () => Navigator.push(
                    //                     context,
                    //                     MaterialPageRoute(
                    //                         builder: (_) =>
                    //                             MoreStoreViewListView(
                    //                                 title: getTranslated(
                    //                                     'more_store',
                    //                                     context))))),
                    //             const SizedBox(
                    //                 height: Dimensions.homePagePadding),
                    //             SizedBox(
                    //                 height: ResponsiveHelper.isTab(context)
                    //                     ? 170
                    //                     : 100,
                    //                 child: const MoreStoreView(
                    //                   isHome: true,
                    //                 ))
                    //           ]))
                    //       : const SizedBox();
                    // }),

                    // const Padding(
                    //     padding:
                    //         EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                    //     child: HomeCategoryProductWidget(isHomePage: true)),
                    // const SizedBox(height: Dimensions.homePagePadding),

                    Consumer<BannerController>(
                        builder: (context, footerBannerProvider, child) {
                      return footerBannerProvider.mainSectionBanner != null
                          ? SingleBannersWidget(
                              bannerModel:
                                  footerBannerProvider.mainSectionBanner,
                              height: MediaQuery.of(context).size.width / 4,
                            )
                          : const SizedBox();
                    }),

                    // Consumer<ProductController>(
                    //     builder: (ctx, prodProvider, child) {
                    //   return Padding(
                    //     padding: const EdgeInsets.fromLTRB(
                    //         Dimensions.paddingSizeDefault,
                    //         0,
                    //         Dimensions.paddingSizeSmall,
                    //         Dimensions.paddingSizeExtraSmall),
                    //     child: Row(children: [
                    //       Expanded(
                    //           child: Text(
                    //               prodProvider.title == 'new_arrival'
                    //                   ? getTranslated('new_arrival', context)!
                    //                   : prodProvider.title!,
                    //               style: titleHeader)),
                    //       prodProvider.latestProductList != null
                    //           ? PopupMenuButton(
                    //               itemBuilder: (context) {
                    //                 return [
                    //                   PopupMenuItem(
                    //                       value: ProductType.newArrival,
                    //                       textStyle: textRegular.copyWith(
                    //                           color:
                    //                               Theme.of(context).hintColor),
                    //                       child: Text(getTranslated(
                    //                           'new_arrival', context)!)),
                    //                   PopupMenuItem(
                    //                       value: ProductType.topProduct,
                    //                       textStyle: textRegular.copyWith(
                    //                           color:
                    //                               Theme.of(context).hintColor),
                    //                       child: Text(getTranslated(
                    //                           'top_product', context)!)),
                    //                   PopupMenuItem(
                    //                       value: ProductType.bestSelling,
                    //                       textStyle: textRegular.copyWith(
                    //                           color:
                    //                               Theme.of(context).hintColor),
                    //                       child: Text(getTranslated(
                    //                           'best_selling', context)!)),
                    //                   PopupMenuItem(
                    //                       value: ProductType.discountedProduct,
                    //                       textStyle: textRegular.copyWith(
                    //                           color:
                    //                               Theme.of(context).hintColor),
                    //                       child: Text(getTranslated(
                    //                           'discounted_product', context)!))
                    //                 ];
                    //               },
                    //               shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(
                    //                       Dimensions.paddingSizeSmall)),
                    //               child: Padding(
                    //                   padding: const EdgeInsets.symmetric(
                    //                       horizontal:
                    //                           Dimensions.paddingSizeSmall,
                    //                       vertical:
                    //                           Dimensions.paddingSizeSmall),
                    //                   child: Image.asset(Images.dropdown,
                    //                       scale: 3)),
                    //               onSelected: (dynamic value) {
                    //                 if (value == ProductType.newArrival) {
                    //                   Provider.of<ProductController>(context,
                    //                           listen: false)
                    //                       .changeTypeOfProduct(value, types[0]);
                    //                 } else if (value ==
                    //                     ProductType.topProduct) {
                    //                   Provider.of<ProductController>(context,
                    //                           listen: false)
                    //                       .changeTypeOfProduct(value, types[1]);
                    //                 } else if (value ==
                    //                     ProductType.bestSelling) {
                    //                   Provider.of<ProductController>(context,
                    //                           listen: false)
                    //                       .changeTypeOfProduct(value, types[2]);
                    //                 } else if (value ==
                    //                     ProductType.discountedProduct) {
                    //                   Provider.of<ProductController>(context,
                    //                           listen: false)
                    //                       .changeTypeOfProduct(value, types[3]);
                    //                 }

                    //                 ProductListWidget(
                    //                     isHomePage: false,
                    //                     productType: value,
                    //                     scrollController: _scrollController);
                    //                 Provider.of<ProductController>(context,
                    //                         listen: false)
                    //                     .getLatestProductList(1, reload: true);
                    //               })
                    //           : const SizedBox(),
                    //     ]),
                    //   );
                    // }),

                    // Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: Dimensions.homePagePadding),
                    //     child: ProductListWidget(
                    //         isHomePage: false,
                    //         productType: ProductType.newArrival,
                    //         scrollController: _scrollController)),
                    // const SizedBox(height: Dimensions.homePagePadding),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverDelegate({required this.child, this.height = 70});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
