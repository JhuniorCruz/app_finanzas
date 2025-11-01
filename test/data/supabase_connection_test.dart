import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase configuration', () {
    late SupabaseClient client;
    late String supabaseUrl;
    late String supabaseAnonKey;

    setUpAll(() async {
      final envFile = File('.env');
      if (!envFile.existsSync()) {
        fail('No se encontro el archivo .env requerido para las credenciales.');
      }

      dotenv.loadFromString(envString: envFile.readAsStringSync());

      supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '').replaceAll("'", '').trim();
      supabaseAnonKey =
          (dotenv.env['SUPABASE_ANON_KEY'] ?? '').replaceAll("'", '').trim();

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        fail('Variables SUPABASE_URL o SUPABASE_ANON_KEY vacias en .env');
      }

      SharedPreferences.setMockInitialValues(const {});

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
      );

      client = Supabase.instance.client;
    });

    test('utiliza la URL y credenciales de Supabase definidas en .env', () {
      final restUri = Uri.parse(client.rest.url);
      expect(restUri.origin, Uri.parse(supabaseUrl).origin);
      expect(restUri.path, startsWith('/rest'));
    });

    test('expone servicios basicos (auth y rest)', () {
      expect(client.auth, isNotNull);
      expect(client.rest, isNotNull);
    });
  });
}
