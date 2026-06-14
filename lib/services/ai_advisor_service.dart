import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiAdvisorService {
  late GenerativeModel _model;
  ChatSession? _chatSession;

  AiAdvisorService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'PEGAR_AQUI_TU_API_KEY') {
      throw Exception('API Key de Gemini no configurada en el archivo .env');
    }

    // Configurar el modelo con instrucciones del sistema estrictas
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('''
Eres un Asesor Financiero Experto y analítico, integrado en una aplicación móvil de control de gastos personales.
Tu único objetivo es proporcionar consejos sobre finanzas personales, reducción de deudas, estrategias de ahorro, presupuestos y educación financiera.

REGLAS ESTRICTAS:
1. SOLO puedes hablar de temas financieros o económicos.
2. Si el usuario pregunta sobre cualquier otro tema (deportes, política, programación general, recetas, chistes, etc.), DEBES negarte cortésmente, recordando que tu función es estrictamente financiera.
3. Tus respuestas deben ser amigables, claras, motivadoras pero realistas.
4. Usa formato Markdown (negritas, listas, saltos de línea) para hacer la lectura fácil.
5. El usuario te proveerá su contexto financiero de forma oculta en el primer mensaje. Basa tus recomendaciones en ese contexto sin mencionar explícitamente "según los datos ocultos que me pasaron". Trata la información como si ya la conocieras de su perfil.
6. Todos los valores monetarios que recibas o menciones están en Soles (moneda de Perú). Usa SIEMPRE el símbolo "S/" y NUNCA uses el símbolo de dólares.
'''),
      generationConfig: GenerationConfig(
        temperature: 0.7, // Balance entre creatividad y precisión
        maxOutputTokens: 8192,
      ),
    );
  }

  /// Inicia el chat inyectando el contexto del usuario en el historial
  void startChatWithContext(String financialContext) {
    _chatSession = _model.startChat(history: [
      Content.text(
          'Hola, soy el sistema. A continuación te paso el contexto actual del usuario. Por favor, tenlo en cuenta para tus respuestas pero no lo repitas. Contexto: $financialContext'),
      Content.model([
        TextPart(
            'Entendido. He analizado el perfil financiero del usuario. Estoy listo para brindarle asesoría personalizada basada en estos datos.')
      ])
    ]);
  }

  /// Envía un mensaje a Gemini y devuelve la respuesta
  Future<String> sendMessage(String message) async {
    if (_chatSession == null) {
      startChatWithContext("No hay datos financieros disponibles por ahora.");
    }
    
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      
      // Limitar el historial para ahorrar tokens (guardamos solo los últimos 10 mensajes = 5 turnos)
      // El historial contiene Content, tenemos que acceder a la lista.
      // GenerativeModel maneja el history internamente en la instancia de ChatSession,
      // pero `history` es una lista final que expone.
      final history = _chatSession!.history.toList();
      if (history.length > 12) {
        // Mantenemos el contexto original (los 2 primeros mensajes) y los últimos 10
        final newHistory = [
          history[0],
          history[1],
          ...history.sublist(history.length - 10)
        ];
        // En google_generative_ai, no podemos reemplazar el history del chat directamente fácilmente,
        // así que creamos un nuevo chat session con el historial recortado.
        _chatSession = _model.startChat(history: newHistory);
      }

      return response.text ?? 'No pude generar una respuesta.';
    } catch (e) {
      return 'Ocurrió un error al intentar conectarme. Por favor, revisa tu conexión a internet o tu API Key.';
    }
  }
}
