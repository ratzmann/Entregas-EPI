import 'dart:typed_data';

/// Usuário do app (técnico de segurança / responsável pela entrega).
class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senhaHash;

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
  });

  factory Usuario.fromMap(Map<String, Object?> m) => Usuario(
    id: m['id'] as int,
    nome: m['nome'] as String,
    email: m['email'] as String,
    senhaHash: m['senha_hash'] as String,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'senha_hash': senhaHash,
  };
}

class Colaborador {
  final int? id;
  final String nome;
  final String cpf;
  final String matricula;
  final String setor;
  final String funcao;
  final bool ativo;

  const Colaborador({
    this.id,
    required this.nome,
    required this.cpf,
    required this.matricula,
    required this.setor,
    required this.funcao,
    this.ativo = true,
  });

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    final primeira = partes.first[0];
    final ultima = partes.length > 1 ? partes.last[0] : '';
    return (primeira + ultima).toUpperCase();
  }

  factory Colaborador.fromMap(Map<String, Object?> m) => Colaborador(
    id: m['id'] as int,
    nome: m['nome'] as String,
    cpf: m['cpf'] as String,
    matricula: m['matricula'] as String,
    setor: m['setor'] as String,
    funcao: m['funcao'] as String,
    ativo: (m['ativo'] as int) == 1,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
    'cpf': cpf,
    'matricula': matricula,
    'setor': setor,
    'funcao': funcao,
    'ativo': ativo ? 1 : 0,
  };
}

/// Equipamento de Proteção Individual. [ca] é o Certificado de Aprovação
/// emitido pelo Ministério do Trabalho; [periodicidadeDias] é o intervalo
/// recomendado de troca.
class Epi {
  final int? id;
  final String nome;
  final String ca;
  final DateTime validadeCa;
  final int estoque;
  final int periodicidadeDias;

  const Epi({
    this.id,
    required this.nome,
    required this.ca,
    required this.validadeCa,
    required this.estoque,
    required this.periodicidadeDias,
  });

  bool get caVencido => validadeCa.isBefore(_hoje());
  bool get estoqueBaixo => estoque <= 5;

  factory Epi.fromMap(Map<String, Object?> m) => Epi(
    id: m['id'] as int,
    nome: m['nome'] as String,
    ca: m['ca'] as String,
    validadeCa: DateTime.parse(m['validade_ca'] as String),
    estoque: m['estoque'] as int,
    periodicidadeDias: m['periodicidade_dias'] as int,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
    'ca': ca,
    'validade_ca': _isoDate(validadeCa),
    'estoque': estoque,
    'periodicidade_dias': periodicidadeDias,
  };
}

class EntregaItem {
  final int epiId;
  final String epiNome;
  final String epiCa;
  final int quantidade;
  final int periodicidadeDias;

  const EntregaItem({
    required this.epiId,
    required this.epiNome,
    required this.epiCa,
    required this.quantidade,
    required this.periodicidadeDias,
  });
}

/// Entrega já registrada, com os nomes resolvidos para exibição.
class Entrega {
  final int id;
  final int colaboradorId;
  final String colaboradorNome;
  final String colaboradorSetor;
  final String responsavelNome;
  final DateTime data;
  final String observacao;
  final List<EntregaItem> itens;
  final Uint8List? assinatura;

  const Entrega({
    required this.id,
    required this.colaboradorId,
    required this.colaboradorNome,
    required this.colaboradorSetor,
    required this.responsavelNome,
    required this.data,
    required this.observacao,
    required this.itens,
    this.assinatura,
  });

  int get totalItens => itens.fold(0, (s, i) => s + i.quantidade);
}

/// Troca de EPI prevista para um colaborador, calculada a partir da última
/// entrega de cada EPI somada à periodicidade.
class TrocaPrevista {
  final String colaboradorNome;
  final int colaboradorId;
  final String epiNome;
  final DateTime vencimento;

  const TrocaPrevista({
    required this.colaboradorNome,
    required this.colaboradorId,
    required this.epiNome,
    required this.vencimento,
  });

  bool get vencida => vencimento.isBefore(_hoje());
}

DateTime _hoje() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
