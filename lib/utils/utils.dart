import 'package:flutter/material.dart';

class Utils {
  static formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';

  static showMessage(String message, BuildContext context, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      backgroundColor: color,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ));
  }

  static List<T> modelBuilder<M, T>(
          List<M> models, T Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, T>((index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();
}
