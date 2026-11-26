import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../core/senha.dart';
import 'models.dart';

class RegraNegocioException implements Exception {
  final String mensagem;
  const RegraNegocioException(this.mensagem);
  @override
  String toString() => mensagem;
}

class UsuarioRepositorio {
  final Database db;
  UsuarioRepositorio(this.db);

  Future<Usuario?> porId(int id) async {
    final r = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    return r.isEmpty ? null : Usuario.fromMap(r.first);
  }

  /// Retorna o usuário se e-mail e senha conferem; caso contrário, null.
  Future<Usuario?> autenticar(String email, String senha) async {
    final r = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (r.isEmpty) return null;
    final u = Usuario.fromMap(r.first);
    return Senha.confere(senha, u.senhaHash) ? u : null;
  }

  Future<Usuario> cadastrar(String nome, String email, String senha) async {
    final emailNorm = email.trim().toLowerCase();
    final existe = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [emailNorm],
      limit: 1,
    );
    if (existe.isNotEmpty) {
      throw const RegraNegocioException('Já existe uma conta com este e-mail.');
    }
    final u = Usuario(
      nome: nome.trim(),
      email: emailNorm,
      senhaHash: Senha.gerarHash(senha),
    );
    final id = await db.insert('usuarios', u.toMap()..remove('id'));
    return Usuario(
      id: id,
      nome: u.nome,
      email: u.email,
      senhaHash: u.senhaHash,
    );
  }
}

class ColaboradorRepositorio {
  final Database db;
  ColaboradorRepositorio(this.db);

  Future<List<Colaborador>> listar({
    String busca = '',
    bool somenteAtivos = false,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (busca.trim().isNotEmpty) {
      where.add('(nome LIKE ? OR matricula LIKE ? OR setor LIKE ?)');
      final b = '%${busca.trim()}%';
      args.addAll([b, b, b]);
    }
    if (somenteAtivos) where.add('ativo = 1');
    final r = await db.query(
      'colaboradores',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'ativo DESC, nome COLLATE NOCASE',
    );
    return r.map(Colaborador.fromMap).toList();
  }

  Future<Colaborador?> porId(int id) async {
    final r = await db.query('colaboradores', where: 'id = ?', whereArgs: [id]);
    return r.isEmpty ? null : Colaborador.fromMap(r.first);
  }

  Future<int> salvar(Colaborador c) async {
    try {
      if (c.id == null) {
        return await db.insert('colaboradores', c.toMap()..remove('id'));
      }
      await db.update(
        'colaboradores',
        c.toMap(),
        where: 'id = ?',
        whereArgs: [c.id],
      );
      return c.id!;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const RegraNegocioException(
          'Já existe um colaborador com este CPF.',
        );
      }
      rethrow;
    }
  }

  Future<int> contarAtivos() async =>
      Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM colaboradores WHERE ativo = 1'),
      ) ??
      0;
}

class EpiRepositorio {
  final Database db;
  EpiRepositorio(this.db);

  Future<List<Epi>> listar({String busca = ''}) async {
    final b = '%${busca.trim()}%';
    final r = await db.query(
      'epis',
      where: busca.trim().isEmpty ? null : '(nome LIKE ? OR ca LIKE ?)',
      whereArgs: busca.trim().isEmpty ? null : [b, b],
      orderBy: 'nome COLLATE NOCASE',
    );
    return r.map(Epi.fromMap).toList();
  }

  Future<int> salvar(Epi e) async {
    if (e.id == null) return db.insert('epis', e.toMap()..remove('id'));
    await db.update('epis', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
    return e.id!;
  }

  /// Só exclui EPIs sem entregas, para preservar o histórico.
  Future<void> excluir(int id) async {
    final usado =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM entrega_itens WHERE epi_id = ?',
            [id],
          ),
        ) ??
        0;
    if (usado > 0) {
      throw const RegraNegocioException(
        'Este EPI já possui entregas registradas e não pode ser excluído.',
      );
    }
    await db.delete('epis', where: 'id = ?', whereArgs: [id]);
  }
}

class NovaEntrega {
  final int colaboradorId;
  final int usuarioId;
  final DateTime data;
  final String observacao;
  final Map<int, int> quantidadePorEpi;
  final Uint8List? assinatura;

  const NovaEntrega({
    required this.colaboradorId,
    required this.usuarioId,
    required this.data,
    required this.quantidadePorEpi,
    this.observacao = '',
    this.assinatura,
  });
}

class EntregaRepositorio {
  final Database db;
  EntregaRepositorio(this.db);

  /// Registra a entrega e baixa o estoque numa única transação: se algum EPI
  /// não tiver saldo suficiente, nada é gravado.
  Future<int> registrar(NovaEntrega nova) async {
    if (nova.quantidadePorEpi.isEmpty) {
      throw const RegraNegocioException('Selecione ao menos um EPI.');
    }
    return db.transaction((txn) async {
      for (final item in nova.quantidadePorEpi.entries) {
        final r = await txn.query(
          'epis',
          columns: ['nome', 'estoque'],
          where: 'id = ?',
          whereArgs: [item.key],
        );
        if (r.isEmpty) throw const RegraNegocioException('EPI não encontrado.');
        final estoque = r.first['estoque'] as int;
        if (item.value <= 0) {
          throw const RegraNegocioException('Quantidade inválida.');
        }
        if (estoque < item.value) {
          throw RegraNegocioException(
            'Estoque insuficiente de "${r.first['nome']}" (disponível: $estoque).',
          );
        }
      }

      final entregaId = await txn.insert('entregas', {
        'colaborador_id': nova.colaboradorId,
        'usuario_id': nova.usuarioId,
        'data': nova.data.toIso8601String(),
        'observacao': nova.observacao.trim(),
        'assinatura': nova.assinatura,
      });
      for (final item in nova.quantidadePorEpi.entries) {
        await txn.insert('entrega_itens', {
          'entrega_id': entregaId,
          'epi_id': item.key,
          'quantidade': item.value,
        });
        await txn.rawUpdate(
          'UPDATE epis SET estoque = estoque - ? WHERE id = ?',
          [item.value, item.key],
        );
      }
      return entregaId;
    });
  }

  Future<List<Entrega>> listar({
    int? colaboradorId,
    String busca = '',
    int? limite,
  }) async {
    final where = <String>[];
    final args = <Object>[];
    if (colaboradorId != null) {
      where.add('en.colaborador_id = ?');
      args.add(colaboradorId);
    }
    if (busca.trim().isNotEmpty) {
      where.add('c.nome LIKE ?');
      args.add('%${busca.trim()}%');
    }
    final linhas = await db.rawQuery('''
      SELECT en.id, en.colaborador_id, en.data, en.observacao,
             c.nome AS colaborador_nome, c.setor AS colaborador_setor,
             u.nome AS responsavel_nome
      FROM entregas en
      JOIN colaboradores c ON c.id = en.colaborador_id
      JOIN usuarios u ON u.id = en.usuario_id
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      ORDER BY en.data DESC, en.id DESC
      ${limite != null ? 'LIMIT $limite' : ''}
    ''', args);
    if (linhas.isEmpty) return [];

    final itens = await _itensDe(linhas.map((l) => l['id'] as int).toList());
    return [
      for (final l in linhas)
        Entrega(
          id: l['id'] as int,
          colaboradorId: l['colaborador_id'] as int,
          colaboradorNome: l['colaborador_nome'] as String,
          colaboradorSetor: l['colaborador_setor'] as String,
          responsavelNome: l['responsavel_nome'] as String,
          data: DateTime.parse(l['data'] as String),
          observacao: l['observacao'] as String,
          itens: itens[l['id']] ?? const [],
        ),
    ];
  }

  /// Carrega uma entrega completa, incluindo a imagem da assinatura.
  Future<Entrega?> porId(int id) async {
    final lista = await db.rawQuery(
      '''
      SELECT en.*, c.nome AS colaborador_nome, c.setor AS colaborador_setor,
             u.nome AS responsavel_nome
      FROM entregas en
      JOIN colaboradores c ON c.id = en.colaborador_id
      JOIN usuarios u ON u.id = en.usuario_id
      WHERE en.id = ?''',
      [id],
    );
    if (lista.isEmpty) return null;
    final l = lista.first;
    final itens = await _itensDe([id]);
    return Entrega(
      id: id,
      colaboradorId: l['colaborador_id'] as int,
      colaboradorNome: l['colaborador_nome'] as String,
      colaboradorSetor: l['colaborador_setor'] as String,
      responsavelNome: l['responsavel_nome'] as String,
      data: DateTime.parse(l['data'] as String),
      observacao: l['observacao'] as String,
      itens: itens[id] ?? const [],
      assinatura: l['assinatura'] as Uint8List?,
    );
  }

  Future<Map<int, List<EntregaItem>>> _itensDe(List<int> ids) async {
    final marcadores = List.filled(ids.length, '?').join(',');
    final r = await db.rawQuery('''
      SELECT i.entrega_id, i.epi_id, i.quantidade, e.nome, e.ca, e.periodicidade_dias
      FROM entrega_itens i JOIN epis e ON e.id = i.epi_id
      WHERE i.entrega_id IN ($marcadores)
      ORDER BY e.nome COLLATE NOCASE''', ids);
    final mapa = <int, List<EntregaItem>>{};
    for (final l in r) {
      mapa
          .putIfAbsent(l['entrega_id'] as int, () => [])
          .add(
            EntregaItem(
              epiId: l['epi_id'] as int,
              epiNome: l['nome'] as String,
              epiCa: l['ca'] as String,
              quantidade: l['quantidade'] as int,
              periodicidadeDias: l['periodicidade_dias'] as int,
            ),
          );
    }
    return mapa;
  }

  Future<int> contarDesde(DateTime inicio) async =>
      Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM entregas WHERE data >= ?', [
          inicio.toIso8601String(),
        ]),
      ) ??
      0;

  /// Trocas vencidas ou que vencem nos próximos [diasAntecedencia] dias,
  /// considerando a entrega mais recente de cada EPI para cada colaborador ativo.
  Future<List<TrocaPrevista>> trocasPrevistas({
    int diasAntecedencia = 15,
  }) async {
    final r = await db.rawQuery('''
      SELECT c.id AS colaborador_id, c.nome AS colaborador_nome,
             e.nome AS epi_nome, e.periodicidade_dias, MAX(en.data) AS ultima
      FROM entrega_itens i
      JOIN entregas en ON en.id = i.entrega_id
      JOIN epis e ON e.id = i.epi_id
      JOIN colaboradores c ON c.id = en.colaborador_id
      WHERE c.ativo = 1
      GROUP BY c.id, e.id''');
    final limite = DateTime.now().add(Duration(days: diasAntecedencia));
    final trocas = <TrocaPrevista>[];
    for (final l in r) {
      final ultima = DateTime.parse(l['ultima'] as String);
      final venc = DateTime(
        ultima.year,
        ultima.month,
        ultima.day,
      ).add(Duration(days: l['periodicidade_dias'] as int));
      if (venc.isBefore(limite)) {
        trocas.add(
          TrocaPrevista(
            colaboradorId: l['colaborador_id'] as int,
            colaboradorNome: l['colaborador_nome'] as String,
            epiNome: l['epi_nome'] as String,
            vencimento: venc,
          ),
        );
      }
    }
    trocas.sort((a, b) => a.vencimento.compareTo(b.vencimento));
    return trocas;
  }
}
