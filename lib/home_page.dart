import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final List currencies;

  const HomePage(this.currencies, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List currencies;
  final List<MaterialColor> _colors = [Colors.blue, Colors.indigo, Colors.red];

  @override
  void initState() {
    super.initState();
    currencies = widget.currencies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crypto Application by Aquib"),
      ),
      body: _cryptoWidget(),
    );
  }

  Widget _cryptoWidget() {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final Map currency = currencies[index];
              final MaterialColor color = _colors[index % _colors.length];
              return CryptoListItem(currency, color);
            },
            itemCount: currencies.length,
          ),
        )
      ],
    );
  }
}

class CryptoListItem extends StatelessWidget {
  final Map currency;
  final MaterialColor color;

  const CryptoListItem(this.currency, this.color);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(currency['name'][0]),
      ),
      title: Text(
        currency['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle:
          _getSubtitleText(currency['priceUsd'], currency['changePercent24Hr']),
    );
  }

  Widget _getSubtitleText(String priceUSD, String percentageChange) {
    TextSpan priceTextWidget = TextSpan(
        text: "\$$priceUSD\n", style: const TextStyle(color: Colors.black));

    String percentageChangeText = "24 hour : $percentageChange%";
    TextSpan percentageChangeTextWidget;

    if (double.parse(percentageChange) > 0) {
      percentageChangeTextWidget = TextSpan(
          text: percentageChangeText,
          style: const TextStyle(color: Colors.red));
    } else {
      percentageChangeTextWidget = TextSpan(
          text: percentageChangeText,
          style: const TextStyle(color: Colors.green));
    }

    return RichText(
      text: TextSpan(children: [priceTextWidget, percentageChangeTextWidget]),
    );
  }
}

Future<List> getCurrencies() async {
  var cryptoUrl = Uri.parse('https://api.coincap.io/v2/assets/?limit=50');

  http.Response response = await http.get(cryptoUrl);

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    if (data.containsKey('data')) {
      List currencies = data['data'];
      return currencies;
    } else {
      throw Exception('Invalid data format in the API response.');
    }
  } else {
    throw Exception('Failed to load currencies');
  }
}
