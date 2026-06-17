import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  //Hold keys
  static const String keyPrice = 'price';
  static const String keyRate = 'interest_rate';
  static const String keyYears = 'loan_years';


  //Save data
  static Future<void> saveData(double price, double rate, int years) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyPrice, price);
    await prefs.setDouble(keyRate, rate);
    await prefs.setInt(keyYears, years);
  }

  //Load data
  static Future<Map<String, dynamic>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyPrice: prefs.getDouble(keyPrice) ?? 0.0,
      keyRate: prefs.getDouble(keyRate) ?? 0.0,
      keyYears: prefs.getInt(keyYears) ?? 10,
    };
  }

}