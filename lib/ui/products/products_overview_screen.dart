import 'package:flutter/material.dart';
import 'package:myshop/ui/cart/cart_screen.dart';
import 'package:myshop/ui/products/products_manager.dart';
import 'package:provider/provider.dart';

import '../cart/cart_manager.dart';
import '../shared/app_drawer.dart';
import 'products_grid.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _currentFilter = FilterOptions.all;
  late Future<void> _fetchProducts;

  @override
  void initState() {
    super.initState();
    _fetchProducts = context.read<ProductsManager>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
// Hiệu chỉnh actions
        actions: <Widget>[
          ProductFilterMenu(
            currentFilter: _currentFilter,
            onFilterSelected: (filter) {
              setState(() {
                _currentFilter = filter;
              });
            },
          ),
          ShoppingCarButton(
            onPressed: () {
              // Chuyển đến trang CartScreen
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        ],
      ),
      // Thêm Drawer
      drawer: const AppDrawer(),
//      body: ProductsGrid(_currentFilter == FilterOptions.favorites),
      body: FutureBuilder(
        future: _fetchProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ProductsGrid(_currentFilter == FilterOptions.favorites);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class ProductFilterMenu extends StatelessWidget {
  const ProductFilterMenu({
    super.key,
    this.currentFilter,
    this.onFilterSelected,
  });

  final FilterOptions? currentFilter;
  final void Function(FilterOptions selectedValue)? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      initialValue: currentFilter,
      onSelected: onFilterSelected,
      icon: const Icon(
        Icons.more_vert,
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: FilterOptions.favorites,
          child: Text('Only Favorites'),
        ),
        const PopupMenuItem(
          value: FilterOptions.all,
          child: Text('Show All'),
        ),
      ],
    );
  }
}

class ShoppingCarButton extends StatelessWidget {
  const ShoppingCarButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (ctx, cartManager, child) {
        return IconButton(
          icon: Badge.count(
            count: cartManager.productCount,
            child: const Icon(
              Icons.shopping_cart,
            ),
          ),
          onPressed: onPressed,
        );
      },
    );
  }
}
