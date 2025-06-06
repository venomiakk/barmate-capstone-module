import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for communicating with Groq AI (Llama 4) to generate a recipe.
class GroqService {
  final String apiKey; // Twój klucz API Groq
  final String endpoint; // Np. https://api.groq.com/openai/v1/chat/completions

  GroqService({required this.apiKey, required this.endpoint});

  /// Wysyła prompt do Groq i zwraca wygenerowany JSON przepisu jako Map
  Future<Map<String, dynamic>?> generateRecipeFromIngredients(List<String> ingredients) async {
    final prompt = '''
You are an expert bartender AI. Using ONLY the following ingredients: ${ingredients.join(', ')}, generate a creative cocktail recipe. 
Return the result as a JSON object with the following fields:
{
  "name": "string",
  "description": "string",
  "ingredients": [
    {
      "name": "string",
      "amount": "string",
      "unit": "string"
    }
  ],
  "steps": [
    {
      "step_number": 1,
      "instruction": "string"
    }
  ]
}
- The 'ingredients' array should use only the provided ingredients.
- The 'amount' and 'unit' fields should be realistic.
- The 'description' should be a short, friendly summary of the drink.
- The 'name' should be catchy and unique.
- Return only valid JSON, no explanation.
''';

    final body = jsonEncode({
      "model": "meta-llama/llama-4-scout-17b-16e-instruct",
      "messages": [
        {
          "role": "user",
          "content": prompt,
        }
      ],
      "temperature": 1,
      "max_completion_tokens": 1024, // <-- poprawiona nazwa pola
      "top_p": 1,
      "stream": false,
      "stop": null,
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Oczekujemy, że odpowiedź jest w polu choices[0].message.content jako string JSON
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null) {
        // Parsujemy string JSON do Mapy
        try {
          // Usuń blok kodu Markdown jeśli występuje
          String cleaned = content.trim();
          if (cleaned.startsWith('```')) {
            cleaned = cleaned.replaceAll(RegExp(r'^```[a-zA-Z]*'), '').trim();
            if (cleaned.endsWith('```')) {
              cleaned = cleaned.substring(0, cleaned.length - 3).trim();
            }
          }
          return jsonDecode(cleaned);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }
}