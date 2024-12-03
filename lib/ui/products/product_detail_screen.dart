import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myshop/ui/cart/cart_manager.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../cart/cart_screen.dart';
import 'products_overview_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product_detail';
  const ProductDetailScreen(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isFavorite = false; // Trạng thái yêu thích ban đầu
  ValueNotifier<int> quantityNotifier =
      ValueNotifier<int>(1); // Quản lý số lượng

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProductsOverviewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CartScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Bắt đầu từ bên phải
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
        actions: [
          // Nút trở về trang chủ
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateToHome(context),
          ),
          // Nút chuyển đến trang giỏ hàng
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _navigateToCart(context),
          ),
          // Nút yêu thích
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(widget.product.imageUrl, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '\$${widget.product.price}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.product.description,
                textAlign: TextAlign.center,
                softWrap: true,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),

            // Chọn số lượng sản phẩm
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 20),
                  ),
                  QuantitySelector(quantityNotifier: quantityNotifier),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Thêm vào giỏ hàng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Chức năng thêm vào giỏ hàng sẽ được xử lý sau
                  final quantity =
                      quantityNotifier.value; // Lấy số lượng từ ValueNotifier
                  // Gửi yêu cầu thêm vào giỏ hàng với số lượng `quantity`
                  // Thêm sản phẩm vào giỏ hàng
                  context.read<CartManager>().addItem(widget.product, quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Added ${widget.product.title} add to cart! Quantity: $quantity.')),
                  );
                  // Lập trình thêm vào giỏ hàng ở đây
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Add To Cart',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatefulWidget {
  const QuantitySelector({super.key, required this.quantityNotifier});

  final ValueNotifier<int> quantityNotifier;

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Gán giá trị ban đầu từ `quantityNotifier`
    _controller =
        TextEditingController(text: widget.quantityNotifier.value.toString());
  }

  void _incrementQuantity() {
    setState(() {
      int currentQuantity = int.tryParse(_controller.text) ?? 1;
      final newQuantity = currentQuantity + 1;
      _controller.text = newQuantity.toString();
      widget.quantityNotifier.value =
          newQuantity; // Cập nhật `quantityNotifier`
    });
  }

  void _decrementQuantity() {
    setState(() {
      int currentQuantity = int.tryParse(_controller.text) ?? 1;
      if (currentQuantity > 1) {
        final newQuantity = currentQuantity - 1;
        _controller.text = newQuantity.toString();
        widget.quantityNotifier.value =
            newQuantity; // Cập nhật `quantityNotifier`
      }
    });
  }

  void _onQuantityChanged(String value) {
    setState(() {
      int? quantity = int.tryParse(value);
      if (quantity == null || quantity < 1) {
        _controller.text = '1';
        widget.quantityNotifier.value = 1; // Đặt lại giá trị hợp lệ
      } else {
        widget.quantityNotifier.value = quantity; // Cập nhật số lượng
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decrementQuantity,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: _onQuantityChanged,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _incrementQuantity,
        ),
      ],
    );
  }
}
