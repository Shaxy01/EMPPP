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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
  String city = 'London'; // Domyślne miasto
  Map<String, dynamic>? weatherData; // Dane pogodowe
  bool isLoading = false; // Flaga ładowania

  // Klucz API z WeatherAPI
  final String apiKey = 'c1c4a39db1794422bae112310241612';

  // Funkcja do pobierania danych z WeatherAPI
  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true; // Rozpoczęcie ładowania
    });

    final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false; // Koniec ładowania
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

  // Dialog wyświetlający błędy
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
  void initState() {
    super.initState();
    fetchWeather(city); // Pobieranie danych przy uruchomieniu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Spinner podczas ładowania
            : weatherData == null
            ? const Text('Brak danych pogodowych.')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Miasto: ${weatherData!['location']['name']}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Temperatura: ${weatherData!['current']['temp_c']}°C',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Warunki: ${weatherData!['current']['condition']['text']}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await fetchWeather(city);
              },
              child: const Text('Odśwież'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCity = await showDialog<String>(
            context: context,
            builder: (context) => CityInputDialog(city: city),
          );

          if (newCity != null && newCity.isNotEmpty) {
            setState(() {
              city = newCity;
            });
            fetchWeather(city);
          }
        },
        tooltip: 'Zmień miasto',
        child: const Icon(Icons.search),
      ),
    );
  }
}

// Dialog do wprowadzania nowego miasta
class CityInputDialog extends StatelessWidget {
  const CityInputDialog({super.key, required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: city);

    return AlertDialog(
      title: const Text('Wprowadź nazwę miasta'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Np. London, Warsaw'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
