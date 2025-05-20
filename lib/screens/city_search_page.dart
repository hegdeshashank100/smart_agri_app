import 'package:flutter/material.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({super.key});

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _cityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final city = _cityController.text.trim();
      Navigator.pushNamed(context, '/weather', arguments: {'city': city});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Enter City Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please enter a city name'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.search),
                label: const Text('Check Forecast'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
