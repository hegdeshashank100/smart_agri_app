import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      home: const AIHome(),
    );
  }
}

class AIHome extends StatefulWidget {
  const AIHome({super.key});

  @override
  State<AIHome> createState() => _AIHomeState();
}

class _AIHomeState extends State<AIHome> {
  File? _image;
  String _result = '';
  bool _isLoading = false;
  String _errorMessage = '';
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = '';
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
      _errorMessage = '';
    });

    try {
      final bytes = await _image!.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        throw Exception('Image size too large (max 2MB)');
      }

      final base64Image = base64Encode(bytes);
      final apiKey = 'AIzaSyCtM8nDKzUuMMscdgGG-G2mpHl6jbDawmg';
      if (apiKey.isEmpty) {
        throw Exception('API key is missing. Please configure GEMINI_API_KEY.');
      }

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      const prompt = '''
Analyze this plant leaf image and provide detailed information about any diseases present.
Structure your response with these sections:
1. Disease Identification: [Name of disease if any, or "Healthy" if no disease]
2. Causes: [Main causes of the disease]
3. Symptoms: [Visible symptoms]
4. Treatment:
   - Organic Remedies: [Home/natural treatments]
   - Commercial Products: [Recommended fungicides/pesticides]
5. Prevention: [How to prevent future occurrences]
Note: Don't Use Bold style for subheaders font Increase font size LEave decent space between one subheading to another it must be well aligned and don't use any special charecter Except ":"
It is important to give decent space
''';

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      },
                    },
                    {'text': prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'];
        if (candidates != null &&
            candidates is List &&
            candidates.isNotEmpty &&
            candidates[0]['content'] != null &&
            candidates[0]['content']['parts'] != null &&
            candidates[0]['content']['parts'].isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'] as String?;
          if (text != null) {
            setState(() {
              _result = text;
            });
          } else {
            throw Exception('No text content in API response');
          }
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _image = null;
      _result = '';
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detector'),
        actions: [
          if (_image != null || _result.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearAll,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_image!, fit: BoxFit.contain),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isLoading ? Colors.grey : null,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : const Text(
                          'Analyze Plant Disease',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child:
                    _isLoading
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : _result.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _result,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        )
                        : const Center(
                          child: Text(
                            'Select a plant leaf image to analyze',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
