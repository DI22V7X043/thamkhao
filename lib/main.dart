import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myshop/ui/screens.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

/*
void main() {
  runApp(const MyApp());
}
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shadowColor: colorScheme.shadow,
        elevation: 4,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthManager(),
        ),
        ChangeNotifierProvider(
          //create: (context) => AuthManager(),
          create: (ctx) => ProductsManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrderManager(),
        ),
      ],
      child: Consumer<AuthManager>(
        builder: (ctx, authManager, child) {
          return MaterialApp(
            title: 'My Shop',
            debugShowCheckedModeBanner: false,
            theme: themeData,

            home: authManager.isAuth
                ? const SafeArea(child: ProductsOverviewScreen())
                : FutureBuilder(
                    future: authManager.tryAutoLogin(),
                    builder: (ctx, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? const SafeArea(child: SplashScreen())
                          : const SafeArea(child: AuthScreen());
                    },
                  ),
            routes: {
              CartScreen.routeName: (ctx) => const SafeArea(
                    child: CartScreen(),
                  ),
              OrdersScreen.routeName: (ctx) => const SafeArea(
                    child: OrdersScreen(),
                  ),
              UserProductsScreen.routeName: (ctx) => const SafeArea(
                    child: UserProductsScreen(),
                  ),
            },
            // onGenerateRoute xử lý các route động
            onGenerateRoute: (settings) {
              // Điều hướng đến ProductDetailScreen khi yêu cầu
              if (settings.name == ProductDetailScreen.routeName) {
                final productId = settings.arguments as String;
                return MaterialPageRoute(
                  //  settings: settings,
                  builder: (ctx) {
                    return SafeArea(
                      child: ProductDetailScreen(
                        //  productId != null
                        //      ? ctx.read<ProductsManager>().findById(productId)
                        //      : null,
                        ProductsManager().findById(productId)!,
                      ),
                    );
                  },
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}


//code lab 1:
/*  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    return MaterialApp(
      title: 'MyShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shadowColor: colorScheme.shadow,
          elevation: 4,
        ),
      ),
      home: SafeArea(
        //child: UserProductsScreen(),
        //child: ProductsOverviewScreen(),
        child: ProductDetailScreen(
          ProductsManager().items[0],
        ),
      ),
    );
  }
  */

