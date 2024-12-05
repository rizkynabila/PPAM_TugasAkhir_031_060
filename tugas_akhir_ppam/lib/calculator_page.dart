import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  Map<String, dynamic> _currencies = {};
  List<String> _currencyList = [];
  String? _fromCurrency;
  String? _toCurrency;
  double _convertedAmount = 0;
  bool _isLoading = true;
  String _error = '';

  String amount = '0';
  String convertedAmount = '0';
  double numOne = 0;
  double numTwo = 0;
  String result = '';
  String finalResult = '0';
  String opr = '';
  String preOpr = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currencies = data['rates'];
          _fromCurrency = 'USD';
          _toCurrency = 'IDR';
          _currencyList = _currencies.keys.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load currencies';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String formatNumber(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  void _selectCurrency(String currencyCode, bool isFromCurrency) {
    setState(() {
      if (isFromCurrency) {
        _fromCurrency = currencyCode;
      } else {
        _toCurrency = currencyCode;
      }
    });
    _convertCurrency();
  }

  void _swapCurrencies() {
    setState(() {
      String? temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convertCurrency();
  }

  void calculation(String btnText) {
    if (btnText == '⌫') {
      resetCalculator();
    } else if (btnText == '=' && opr.isNotEmpty) {
      numTwo =
          double.parse(result.isNotEmpty ? result.replaceAll(',', '') : '0');
      finalResult = performOperation(opr);
      opr = '';
      result = finalResult;
    } else if ('+-x/'.contains(btnText)) {
      if (result.isNotEmpty) {
        numOne = double.parse(result.replaceAll(',', ''));
      }
      opr = btnText;
      result = '';
    } else {
      result += btnText;
      finalResult = result;
    }

    setState(() {
      amount = formatNumber(double.parse(finalResult.replaceAll(',', '')));
      _convertCurrency();
    });
  }

  void resetCalculator() {
    setState(() {
      result = '';
      finalResult = '0';
      numOne = 0;
      numTwo = 0;
      opr = '';
      preOpr = '';
    });
  }

  String performOperation(String operation) {
    switch (operation) {
      case '+':
        return add();
      case '-':
        return sub();
      case 'x':
        return mul();
      case '/':
        return div();
      default:
        return '0';
    }
  }

  String add() => doesContainDecimal((numOne + numTwo).toStringAsFixed(2));
  String sub() => doesContainDecimal((numOne - numTwo).toStringAsFixed(2));
  String mul() => doesContainDecimal((numOne * numTwo).toStringAsFixed(2));
  String div() {
    if (numTwo == 0) return 'Error';
    return doesContainDecimal((numOne / numTwo).toStringAsFixed(2));
  }

  String doesContainDecimal(String result) {
    if (result.contains('.') && double.parse(result.split('.')[1]) == 0) {
      return result.split('.')[0];
    }
    return result;
  }

  void _convertCurrency() {
    if (_fromCurrency != null && _toCurrency != null && amount.isNotEmpty) {
      double fromRate = (_currencies[_fromCurrency] as num).toDouble();
      double toRate = (_currencies[_toCurrency] as num).toDouble();
      setState(() {
        _convertedAmount =
            (double.parse(amount.replaceAll(',', '')) / fromRate) * toRate;
        convertedAmount = formatNumber(_convertedAmount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child:
                      Text(_error, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CurrencySelectionField(
                        label: _fromCurrency ?? 'Select From Currency',
                        amount: amount,
                        onTap: () => _showCurrencyDialog(true),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _swapCurrencies,
                        child: const Icon(Icons.swap_vert, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      CurrencySelectionField(
                        label: _toCurrency ?? 'Select To Currency',
                        amount: convertedAmount,
                        onTap: () => _showCurrencyDialog(false),
                      ),
                      const SizedBox(height: 25),
                      NumPadGrid(onPress: calculation),
                    ],
                  ),
                ),
    );
  }

  void _showCurrencyDialog(bool isFromCurrency) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              isFromCurrency ? 'Select From Currency' : 'Select To Currency'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _currencyList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_currencyList[index]),
                  onTap: () {
                    _selectCurrency(_currencyList[index], isFromCurrency);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class CurrencySelectionField extends StatelessWidget {
  final String label;
  final String amount;
  final VoidCallback onTap;

  const CurrencySelectionField({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(amount, style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class NumPadGrid extends StatelessWidget {
  final Function(String) onPress;

  const NumPadGrid({required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 365,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: numpadItems.length,
        itemBuilder: (context, index) {
          final item = numpadItems[index];
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: item['color'] as Color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200)),
              padding: EdgeInsets.zero,
            ),
            onPressed: () => onPress(item['label'] as String),
            child: Text(item['label'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 20)),
          );
        },
      ),
    );
  }
}

List<Map<String, dynamic>> numpadItems = [
  {'label': '+', 'color': Colors.orange},
  {'label': '1', 'color': const Color(0xFF2E2E2E)},
  {'label': '2', 'color': const Color(0xFF2E2E2E)},
  {'label': '3', 'color': const Color(0xFF2E2E2E)},
  {'label': '-', 'color': Colors.orange},
  {'label': '4', 'color': const Color(0xFF2E2E2E)},
  {'label': '5', 'color': const Color(0xFF2E2E2E)},
  {'label': '6', 'color': const Color(0xFF2E2E2E)},
  {'label': 'x', 'color': Colors.orange},
  {'label': '7', 'color': const Color(0xFF2E2E2E)},
  {'label': '8', 'color': const Color(0xFF2E2E2E)},
  {'label': '9', 'color': const Color(0xFF2E2E2E)},
  {'label': '=', 'color': Colors.orange},
  {'label': '/', 'color': Colors.orange},
  {'label': '0', 'color': const Color(0xFF2E2E2E)},
  {'label': '⌫', 'color': Colors.red},
];
