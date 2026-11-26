import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/senha.dart';

/// Abre o banco SQLite local do app e cria o esquema na primeira execução.
class AppDatabase {
  AppDatabase._();

  static const _nomeArquivo = 'entregas_epi.db';
  static const _versao = 1;

  /// [caminho] permite usar um banco em memória nos testes.
  static Future<Database> abrir({
    String? caminho,
    bool comDadosDemo = true,
  }) async {
    final destino = caminho ?? p.join(await getDatabasesPath(), _nomeArquivo);
    return openDatabase(
      destino,
      version: _versao,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await _criarEsquema(db);
        if (comDadosDemo) await _inserirDadosDemo(db);
      },
    );
  }

  static Future<void> _criarEsquema(Database db) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          senha_hash TEXT NOT NULL
        )''')
      ..execute('''
        CREATE TABLE colaboradores (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          cpf TEXT NOT NULL UNIQUE,
          matricula TEXT NOT NULL,
          setor TEXT NOT NULL,
          funcao TEXT NOT NULL,
          ativo INTEGER NOT NULL DEFAULT 1
        )''')
      ..execute('''
        CREATE TABLE epis (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          ca TEXT NOT NULL,
          validade_ca TEXT NOT NULL,
          estoque INTEGER NOT NULL CHECK (estoque >= 0),
          periodicidade_dias INTEGER NOT NULL
        )''')
      ..execute('''
        CREATE TABLE entregas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          colaborador_id INTEGER NOT NULL REFERENCES colaboradores(id),
          usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
          data TEXT NOT NULL,
          observacao TEXT NOT NULL DEFAULT '',
          assinatura BLOB
        )''')
      ..execute('''
        CREATE TABLE entrega_itens (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entrega_id INTEGER NOT NULL REFERENCES entregas(id) ON DELETE CASCADE,
          epi_id INTEGER NOT NULL REFERENCES epis(id),
          quantidade INTEGER NOT NULL CHECK (quantidade > 0)
        )''')
      ..execute('CREATE INDEX idx_entregas_colab ON entregas(colaborador_id)')
      ..execute('CREATE INDEX idx_itens_entrega ON entrega_itens(entrega_id)');
    await batch.commit(noResult: true);
  }

  /// Dados de exemplo para a apresentação do trabalho. Os números de CA são
  /// fictícios.
  static Future<void> _inserirDadosDemo(Database db) async {
    final batch = db.batch();
    batch.insert('usuarios', {
      'nome': 'Técnico HC',
      'email': 'admin@hc.com',
      'senha_hash': Senha.gerarHash('hc123456'),
    });

    final epis = [
      ('Capacete de segurança classe B', '31469', '2028-03-10', 40, 730),
      ('Óculos de proteção incolor', '10346', '2027-08-22', 60, 180),
      ('Protetor auricular tipo plug', '5745', '2027-01-15', 120, 30),
      ('Luva nitrílica', '38150', '2026-12-05', 4, 15),
      ('Botina de segurança com bico', '42291', '2028-06-30', 18, 365),
      ('Respirador PFF2', '39203', '2026-10-01', 35, 7),
    ];
    for (final e in epis) {
      batch.insert('epis', {
        'nome': e.$1,
        'ca': e.$2,
        'validade_ca': e.$3,
        'estoque': e.$4,
        'periodicidade_dias': e.$5,
      });
    }

    final colaboradores = [
      (
        'Ana Paula Schmitt',
        '123.456.789-09',
        '1021',
        'Produção',
        'Operadora de máquinas',
      ),
      (
        'Carlos Eduardo Vieira',
        '987.654.321-00',
        '1034',
        'Manutenção',
        'Eletricista',
      ),
      (
        'Juliana Becker',
        '111.444.777-35',
        '1102',
        'Almoxarifado',
        'Auxiliar de estoque',
      ),
      ('Marcos Antônio Rosa', '529.982.247-25', '1150', 'Produção', 'Soldador'),
    ];
    for (final c in colaboradores) {
      batch.insert('colaboradores', {
        'nome': c.$1,
        'cpf': c.$2,
        'matricula': c.$3,
        'setor': c.$4,
        'funcao': c.$5,
      });
    }
    await batch.commit(noResult: true);
  }
}
