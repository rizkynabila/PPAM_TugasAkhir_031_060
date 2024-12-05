import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  Map<String, dynamic> _currencies = {};
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Method to fetch currency data
  Future<void> _fetchData() async {
    try {
      final currenciesResponse = await http
          .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

      if (currenciesResponse.statusCode == 200) {
        final currenciesData = json.decode(currenciesResponse.body);

        setState(() {
          _currencies = currenciesData['rates'];
          _isLoading = false;
        });
      } else {
        _handleError('Failed to load data');
      }
    } catch (e) {
      _handleError('Error: $e');
    }
  }

  // Error handling method
  void _handleError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter currencies based on the search query
    final filteredCurrencies = _currencies.entries.where((entry) {
      final currencyKey = entry.key.toLowerCase();
      return currencyKey.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Currencies'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Currency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : filteredCurrencies.isEmpty
                        ? const Center(child: Text('No currencies found'))
                        : ListView.builder(
                            itemCount: filteredCurrencies.length,
                            itemBuilder: (context, index) {
                              final currencyKey = filteredCurrencies[index].key;
                              final currencyValue =
                                  filteredCurrencies[index].value;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: ListTile(
                                  title: Text(
                                    currencyKey.toUpperCase(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  trailing: Text(
                                    '${currencyValue.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.green),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
