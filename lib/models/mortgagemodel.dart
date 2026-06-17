import 'package:flutter/material.dart';
import 'dart:math';

class MortgageProvider extends ChangeNotifier {
  double _price = 0.0;
  double _interestRate = 0.0;
  int _years = 10;

  // Getters
  double get price => _price;
  double get interestRate => _interestRate;
  int get years => _years;

  // Set state and notify listeners of state change
  set price(double price) {
    _price = price;
    notifyListeners();
  }
  
  set interestRate(double interestRate) {
    _interestRate = interestRate;
    notifyListeners();
  }
  
  set years(int years) {
    _years = years;
    notifyListeners();
  }

  // Monthly payment helper function
  double monthlyPayment() {
    if (_price <= 0 || _interestRate <= 0 || _years <= 0) {
      return 0.0;
    }
    double mRate = (_interestRate / 100) / 12;
    double temp = pow(1 / (1 + mRate), years * 12).toDouble();
    return _price * mRate / (1 - temp);
  }

  // Calcualte total payment
  double totalPayment() {
    return monthlyPayment() * (_years * 12);
  }
}