import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CryptoCurrencyPage extends StatefulWidget {
  const CryptoCurrencyPage({super.key});

  @override
  State<CryptoCurrencyPage> createState() => _CryptoCurrencyPageState();
}

class _CryptoCurrencyPageState extends State<CryptoCurrencyPage> {
  List<dynamic> _cryptocurrencies = [];
  List<dynamic> _filteredCryptocurrencies = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCryptocurrencies();
    _searchController.addListener(_filterCryptocurrencies);
  }

  // Method for fetching cryptocurrencies
  Future<void> _fetchCryptocurrencies() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cryptocurrencies = data;
          _filteredCryptocurrencies = data;
          _isLoading = false;
        });
      } else {
        _handleError('Failed to load cryptocurrencies');
      }
    } catch (e) {
      _handleError('Error: $e');
    }
  }

  // Error handling helper method
  void _handleError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  // Filtering cryptocurrencies based on search query
  void _filterCryptocurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCryptocurrencies = _cryptocurrencies.where((crypto) {
        return crypto['name'].toLowerCase().contains(query) ||
            crypto['symbol'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cryptocurrency Prices'),
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Cryptocurrency',
                border: OutlineInputBorder(),
              ),
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
                    : _filteredCryptocurrencies.isEmpty
                        ? const Center(child: Text("No results found"))
                        : ListView.builder(
                            itemCount: _filteredCryptocurrencies.length,
                            itemBuilder: (context, index) {
                              final crypto = _filteredCryptocurrencies[index];
                              return _buildCryptoCard(crypto, numberFormat);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each cryptocurrency card
  Widget _buildCryptoCard(dynamic crypto, NumberFormat numberFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Image.network(
          crypto['image'],
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        title: Text(
          crypto['name'],
          style: const TextStyle(fontSize: 18),
        ),
        subtitle: Text(
          'Symbol: ${crypto['symbol'].toUpperCase()}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Text(
          numberFormat.format(crypto['current_price']),
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
      ),
    );
  }
}
