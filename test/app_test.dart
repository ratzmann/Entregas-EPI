import 'package:entregas_epi/core/formatos.dart';
import 'package:entregas_epi/core/senha.dart';
import 'package:entregas_epi/data/database.dart';
import 'package:entregas_epi/data/repositorios.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Formatos', () {
    test('valida CPF', () {
      expect(Formatos.cpfValido('529.982.247-25'), isTrue);
      expect(Formatos.cpfValido('52998224725'), isTrue);
      expect(Formatos.cpfValido('529.982.247-26'), isFalse);
      expect(Formatos.cpfValido('111.111.111-11'), isFalse);
    });

    test('formata periodicidade', () {
      expect(Formatos.periodicidade(365), '1 ano');
      expect(Formatos.periodicidade(90), '3 meses');
      expect(Formatos.periodicidade(7), '7 dias');
    });
  });

  test('hash de senha confere só com a senha correta', () {
    final h = Senha.gerarHash('segredo');
    expect(Senha.confere('segredo', h), isTrue);
    expect(Senha.confere('outra', h), isFalse);
    expect(h, isNot(contains('segredo')));
  });

  group('Banco de dados', () {
    late Database db;

    setUp(() async {
      db = await AppDatabase.abrir(caminho: inMemoryDatabasePath);
    });
    tearDown(() => db.close());

    test('autentica o usuário de demonstração', () async {
      final repo = UsuarioRepositorio(db);
      expect(await repo.autenticar('admin@hc.com', 'hc123456'), isNotNull);
      expect(await repo.autenticar('ADMIN@hc.com ', 'hc123456'), isNotNull);
      expect(await repo.autenticar('admin@hc.com', 'errada'), isNull);
    });

    test('não permite e-mail duplicado', () async {
      final repo = UsuarioRepositorio(db);
      expect(
        () => repo.cadastrar('Outro', 'admin@hc.com', '123456'),
        throwsA(isA<RegraNegocioException>()),
      );
    });

    test('registrar entrega baixa o estoque', () async {
      final epis = EpiRepositorio(db);
      final entregas = EntregaRepositorio(db);
      final capacete = (await epis.listar(busca: 'Capacete')).single;

      final id = await entregas.registrar(
        NovaEntrega(
          colaboradorId: 1,
          usuarioId: 1,
          data: DateTime.now(),
          quantidadePorEpi: {capacete.id!: 2},
        ),
      );

      final depois = (await epis.listar(busca: 'Capacete')).single;
      expect(depois.estoque, capacete.estoque - 2);
      final entrega = await entregas.porId(id);
      expect(entrega!.itens.single.quantidade, 2);
      expect(await entregas.listar(colaboradorId: 1), hasLength(1));
    });

    test('estoque insuficiente não grava nada', () async {
      final epis = EpiRepositorio(db);
      final entregas = EntregaRepositorio(db);
      final luva = (await epis.listar(busca: 'Luva')).single;
      final capacete = (await epis.listar(busca: 'Capacete')).single;

      await expectLater(
        entregas.registrar(
          NovaEntrega(
            colaboradorId: 1,
            usuarioId: 1,
            data: DateTime.now(),
            quantidadePorEpi: {capacete.id!: 1, luva.id!: luva.estoque + 1},
          ),
        ),
        throwsA(isA<RegraNegocioException>()),
      );

      expect(
        (await epis.listar(busca: 'Capacete')).single.estoque,
        capacete.estoque,
      );
      expect(await entregas.listar(), isEmpty);
    });

    test('aponta troca vencida pela periodicidade', () async {
      final epis = EpiRepositorio(db);
      final pff2 = (await epis.listar(busca: 'PFF2'))
          .single; // troca a cada 7 dias
      await EntregaRepositorio(db).registrar(
        NovaEntrega(
          colaboradorId: 2,
          usuarioId: 1,
          data: DateTime.now().subtract(const Duration(days: 10)),
          quantidadePorEpi: {pff2.id!: 1},
        ),
      );

      final trocas = await EntregaRepositorio(db).trocasPrevistas();
      expect(trocas.single.vencida, isTrue);
      expect(trocas.single.colaboradorId, 2);
    });
  });
}
