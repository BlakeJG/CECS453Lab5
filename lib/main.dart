import 'package:flutter/material.dart';

// Import stuff needed
import 'package:provider/provider.dart';
import 'models/mortgagemodel.dart';
import 'preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedData = await Preferences.loadData();
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        // Add initial data from saved preferences to the provider
        final provider = MortgageProvider();
        provider.price = savedData[Preferences.keyPrice] ?? 0.0;
        provider.interestRate = savedData[Preferences.keyRate] ?? 0.0;
        provider.years = savedData[Preferences.keyYears] ?? 10;
        return provider;
      },
      child: const MainApp()
    )
  );
}

// saveValues helper function
void saveValues(BuildContext context, MortgageProvider mort) async { 
  await Preferences.saveData(
    mort.price,
    mort.interestRate,
    mort.years,
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MortgageCalculator());
  }
}

class MortgageCalculator extends StatefulWidget {
  const MortgageCalculator({super.key});

  @override
  State<MortgageCalculator> createState() => _MortgageCalculatorState();
}

class _MortgageCalculatorState extends State<MortgageCalculator> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  int _selectedyear = 10;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    final mort = context.read<MortgageProvider>();
    _priceController.text = mort.price > 0 ? mort.price.toString() : '';
    _rateController.text = mort.interestRate > 0 ? mort.interestRate.toString() : '';
    _selectedyear = mort.years;
  }

  @override
  Widget build(BuildContext context) {
    // context.watch to listen for changes
    final mort = context.watch<MortgageProvider>(); // Update provider

    return Scaffold(
      appBar: AppBar(title: Text("Mortgage Calculator", style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue,),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _priceController,
              onChanged: (value) {
                mort.price = double.tryParse(value) ?? 0.0;
              },
              decoration: InputDecoration(labelText: 'Amount'),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _rateController,
              onChanged: (value) {
                mort.interestRate = double.tryParse(value) ?? 0.0;
              },
              decoration: InputDecoration(labelText: 'Interest Rate %'),
            ),
          ),
          // Radio Group for mutually exclusive RadioButtons
          RadioGroup<int>(
            groupValue: _selectedyear,
            onChanged: (int? value) {
              if (value != null) {
                mort.years = value; // Update the value in the provider
              }
              setState(() {
                _selectedyear = mort.years;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Text("Years:"),
                  Expanded(
                    child: RadioListTile<int>(title: Text("10"), value: 10),
                  ),
                  Expanded(
                    child: RadioListTile<int>(title: Text("15"), value: 15),
                  ),
                  Expanded(
                    child: RadioListTile<int>(title: Text("30"), value: 30),
                  ),
                ],
              ),
            )
          ),
          // Terms and Conditions Checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: (bool? value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Terms and Conditions'),
                        content: const Text('Please confirm you agree to the terms.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _termsAccepted = !_termsAccepted;
                              });
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Text('Terms and Conditions'),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              saveValues(context, mort); // Save to preferences
              Navigator.push(context, MaterialPageRoute(builder: (context) => CalculationScreen()),); // Go to next screen
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }
}

class CalculationScreen extends StatelessWidget {
  const CalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch to listen for changes
    final mort = context.read<MortgageProvider>(); // Read from provider to display

    return Scaffold(
      appBar: AppBar(title: Text("Calculation Results", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,), automaticallyImplyLeading: false, backgroundColor: Colors.blue),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Container(decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.all(10), 
            child: Column(
              children: <Widget>[
                Text("Amount: \$${mort.price}", style: TextStyle(color: Colors.white, fontSize: 16),),
                Text("Years: ${mort.years}", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("Interest Rate: ${(mort.interestRate).toStringAsFixed(2)}%", style: TextStyle(color: Colors.white,fontSize: 16),),
                Text("Monthly Payment: \$${mort.monthlyPayment().isFinite ? mort.monthlyPayment().toStringAsFixed(2) : 'N/A'}", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              )
            ),
            Text("Total with Interest: \$${mort.totalPayment().toStringAsFixed(2)}", style: TextStyle(fontSize: 22)),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to other screen to modify data
              }, 
              child: Text('Modify Data')
            )
          ],
        ),
      ),
    );
  }
}