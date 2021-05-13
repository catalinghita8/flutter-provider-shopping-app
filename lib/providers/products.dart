import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items =[];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchProducts() async {
    final baseUrl =
        "https://flutter-dummy-server-default-rtdb.firebaseio.com/products.json";
    try {
      final response = await http.get(baseUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> productsLoaded = [];
      extractedData.forEach((productId, productContent) {
        productsLoaded.insert(0,
            Product(
              id: productId,
              title: productContent["title"],
              description: productContent["description"],
              price: productContent["price"],
              isFavorite: productContent["isFavorite"],
              imageUrl: productContent["imageUrl"],
            ));
      });
      _items = productsLoaded;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addProduct(Product product) async {
    final baseUrl =
        "https://flutter-dummy-server-default-rtdb.firebaseio.com/products.json";
    try {
      final response = await http.post(
        baseUrl,
        body: jsonEncode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "isFavourite": product.isFavorite,
        }),
      );
      final newId = json.decode(response.body)["name"];
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: newId,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
