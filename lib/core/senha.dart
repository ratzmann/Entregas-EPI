import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hash de senha com salt aleatório (formato `salt:hash`), para não guardar
/// senhas em texto puro no SQLite.
class Senha {
  Senha._();

  static String gerarHash(String senha) {
    final rnd = Random.secure();
    final salt = base64Url.encode(List.generate(16, (_) => rnd.nextInt(256)));
    return '$salt:${_digest(salt, senha)}';
  }

  static bool confere(String senha, String armazenado) {
    final partes = armazenado.split(':');
    if (partes.length != 2) return false;
    return _digest(partes[0], senha) == partes[1];
  }

  static String _digest(String salt, String senha) =>
      sha256.convert(utf8.encode('$salt$senha')).toString();
}
