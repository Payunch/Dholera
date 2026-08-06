import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiHomeScreen extends StatefulWidget {
  const GeminiHomeScreen({super.key});

  @override
  State<GeminiHomeScreen> createState() => _GeminiHomeScreenState();
}

class _GeminiHomeScreenState extends State<GeminiHomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Retrieve API key securely from flutter_dotenv
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // Initialize Gemini model
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<void> _generateText() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final content = [Content.text(_controller.text)];
      final response = await _model.generateContent(content);

      setState(() {
        _response = response.text ?? 'No output generated.';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dholera AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ask Gemini...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateText,
              child: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Text('Send'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
