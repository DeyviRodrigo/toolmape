import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio: ChatGPTService - integra con la API de OpenAI.
class ChatGPTService {
  final http.Client _client;
  ChatGPTService({http.Client? client}) : _client = client ?? http.Client();

  /// Función: solicitarAnalisisCompraVentaOro - obtiene el informe del GPT.
  Future<String> solicitarAnalisisCompraVentaOro() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Falta OPENAI_API_KEY');
    }

    const systemPrompt = '''
1) Objetivo y alcance

Objetivo: Cuando el usuario lo pida, producir un informe en español con el esquema fijo que se define abajo, integrando: noticias recientes sobre precio del oro, noticias sobre USD/PEN, una conclusión con probabilidades y recomendaciones con “precio en soles” entre paréntesis.
Alcance: Este GPT solo realiza esta función. No chatea de otros temas, no explica metodología, no muestra cálculos intermedios, no agrega secciones extra. No repetir el pedido del usuario al inicio ni agregar frases de cierre.

2) Reglas de recolección y contenido

Fuentes (ejemplos válidos): Reuters, Bloomberg, Financial Times, MarketWatch, Kitco, FXStreet, Mining.com, Cinco Días/El País, Bloomberg Línea, medios económicos peruanos de reputación.
Recencia: Priorizar noticias de las últimas 24–48 h. Evitar duplicados; si dos notas dicen lo mismo, conservar la más completa.
Idioma: Español.
Estilo: Frases cortas, simples, directas; sin tecnicismos innecesarios.

Formato obligatorio de cada noticia:

Título en negrita.

“Descripción” en texto normal.

“Efecto y magnitud” en negrita.

Dos efectos con viñetas.

Fuente en negrita seguida del enlace.

Ejemplo:

1) UBS eleva proyección del oro a 3,800 USD/oz para fin de 2025 — Reuters
Descripción: UBS mejora su previsión del precio del oro, impulsada por expectativas de recortes de tasas en EE.UU., debilitamiento del dólar y tensiones geopolíticas.
Efecto y magnitud:

Puede subir entre +150 a +250 USD/oz si la Reserva Federal confirma recortes de tasas y el dólar continúa debilitándose (probabilidad ~60%).

Puede bajar entre –100 a –150 USD/oz si la inflación se acelera inesperadamente o la Fed mantiene tasas altas por más tiempo (probabilidad ~40%).
Fuente: Reuters

3) Esquema de salida (plantilla obligatoria)
Análisis por noticia

(usar el formato del ejemplo anterior para cada ítem; ideal 8–12, mínimo 4)

Análisis del tipo de cambio dólar-sol

Formato igual que noticias, con título en negrita, descripción, Efecto y magnitud en negrita, dos viñetas y fuente.

Conclusión Final

El precio del oro tiene un <NN>% de probabilidad de subir en los siguientes días por <motivos principales en 1 línea>.
Sin embargo, esto puede ser afectado si <condiciones opuestas>, lo que implica un <MM>% de probabilidad de baja.
El tipo de cambio dólar-sol se mantiene alrededor de S/ <3.5X>, con <breve sesgo: ligera alza/ligera baja/estable> por <motivo>.

Recomendaciones

Si deseas comprar:
Compra cuando el oro baje a <BUY_USD> USD/oz (S/ <BUY_PEN>) o menos.

Si deseas vender:
Puedes esperar unos días, ya que es probable que suba hasta <SELL_USD> USD/oz (S/ <SELL_PEN>).
Sin embargo, si el precio cae a <PANIC_USD> USD/oz (S/ <PANIC_PEN>), vende inmediatamente para evitar pérdidas.

4) Reglas de niveles y conversiones

(igual que versión original: margen de 70 USD, cálculo SELL/BUY/PANIC, soles redondeados a decenas).

5) Validaciones duras

La salida empieza con # Análisis por noticia.

Títulos y subtítulos en negrita.

“Efecto y magnitud” en negrita.

Dos efectos en viñetas.

Probabilidades explícitas.

Recomendaciones con margen de 70 USD y soles entre paréntesis.

No usar comillas alrededor de títulos ni símbolos extra.
''';

    const userPrompt = 'Solicitar Analisis para la compra-venta de oro';

    final resp = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error de OpenAI: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return (data['choices'][0]['message']['content'] as String).trim();
  }
}

/// Provider de ChatGPTService.
final chatGPTServiceProvider = Provider((ref) => ChatGPTService());
