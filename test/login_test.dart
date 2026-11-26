import 'package:entregas_epi/app.dart';
import 'package:entregas_epi/data/database.dart';
import 'package:entregas_epi/data/repositorios.dart';
import 'package:entregas_epi/services/app_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// O banco faz I/O real; deixa as operações pendentes terminarem e redesenha.
  Future<void> aguardarBanco(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
  }

  testWidgets('login inválido avisa e login válido abre o painel', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final (db, prefs) = (await tester.runAsync(
      () async => (
        await AppDatabase.abrir(caminho: inMemoryDatabasePath),
        await SharedPreferences.getInstance(),
      ),
    ))!;
    final sessao = Sessao(UsuarioRepositorio(db), prefs);

    await tester.pumpWidget(
      AppServices(db: db, sessao: sessao, child: const EntregasEpiApp()),
    );
    expect(find.text('ENTRAR'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'admin@hc.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');
    await tester.tap(find.text('ENTRAR'));
    await aguardarBanco(tester);
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), 'hc123456');
    await tester.tap(find.text('ENTRAR'));
    await aguardarBanco(tester);

    expect(find.text('Olá, Técnico'), findsOneWidget);
    expect(find.text('NOVA ENTREGA'), findsOneWidget);
    expect(prefs.getInt('usuario_logado_id'), 1);

    await tester.runAsync(db.close);
  });
}
