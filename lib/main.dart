import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja Pogodowa',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Pogoda - WeatherAPI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedCountry = 'Wielka Brytania';
  String selectedCity = 'Londyn';
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  final String apiKey = 'c1c4a39db1794422bae112310241612';

  final Map<String, List<String>> countriesAndCities = {
    'Wielka Brytania': ['Londyn', 'Manchester', 'Liverpool'],
    'Stany Zjednoczone': ['New York', 'Los Angeles', 'Chicago'],
    'Japonia': ['Tokio', 'Kioto', 'Osaka'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane'],
    'Francja': ['Paryż', 'Marsylia', 'Lyon'],
    'Polska': ['Warszawa', 'Krakow', 'Wroclaw']
  };

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${Uri.encodeComponent(city)}&lang=pl');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Błąd pobierania danych: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog('Nie udało się pobrać danych pogodowych. Spróbuj ponownie.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Błąd'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedCountry,
                    items: countriesAndCities.keys.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newCountry) {
                      setState(() {
                        selectedCountry = newCountry ?? selectedCountry;
                        selectedCity = countriesAndCities[selectedCountry]!.first;
                        fetchWeather(selectedCity);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedCity,
                    items: countriesAndCities[selectedCountry]!.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newCity) {
                      setState(() {
                        selectedCity = newCity ?? selectedCity;
                        fetchWeather(selectedCity);
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  if (isLoading) ...[
                    const CircularProgressIndicator(),
                  ] else if (weatherData != null) ...[
                    Text('Miasto: ${weatherData!['location']['name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Temperatura: ${weatherData!['current']['temp_c']} °C', style: const TextStyle(fontSize: 18)),
                    Text('Stan: ${weatherData!['current']['condition']['text']}', style: const TextStyle(fontSize: 18)),
                    Text('Wilgotność: ${weatherData!['current']['humidity']}%', style: const TextStyle(fontSize: 18)),
                    Text('Prędkość wiatru: ${weatherData!['current']['wind_kph']} km/h', style: const TextStyle(fontSize: 18)),
                  ] else ...[
                    const Text('Wybierz kraj i miasto, aby zobaczyć pogodę.', style: TextStyle(fontSize: 18)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
