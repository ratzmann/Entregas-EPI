/// Formatação e validação em pt-BR sem depender do pacote intl.
class Formatos {
  Formatos._();

  static const _meses = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  static String _doisDigitos(int n) => n.toString().padLeft(2, '0');

  /// 25/11/2026
  static String data(DateTime d) =>
      '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';

  /// 25/11/2026 às 14:05
  static String dataHora(DateTime d) =>
      '${data(d)} às ${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

  /// 25 nov
  static String diaMes(DateTime d) => '${d.day} ${_meses[d.month - 1]}';

  static String iso(DateTime d) => d.toIso8601String();

  /// Converte "dd/mm/aaaa" em data; retorna null se inválida.
  static DateTime? parseData(String texto) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
    if (m == null) return null;
    final d = int.parse(m[1]!), mes = int.parse(m[2]!), a = int.parse(m[3]!);
    final dt = DateTime(a, mes, d);
    if (dt.day != d || dt.month != mes) return null;
    return dt;
  }

  static String periodicidade(int dias) {
    if (dias % 365 == 0) {
      final anos = dias ~/ 365;
      return anos == 1 ? '1 ano' : '$anos anos';
    }
    if (dias % 30 == 0) {
      final meses = dias ~/ 30;
      return meses == 1 ? '1 mês' : '$meses meses';
    }
    return dias == 1 ? '1 dia' : '$dias dias';
  }

  static String somenteDigitos(String s) => s.replaceAll(RegExp(r'\D'), '');

  static String cpf(String s) {
    final d = somenteDigitos(s);
    if (d.length != 11) return s;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }

  /// Valida os dígitos verificadores do CPF.
  static bool cpfValido(String s) {
    final d = somenteDigitos(s).split('').map(int.parse).toList();
    if (d.length != 11 || d.every((x) => x == d[0])) return false;
    for (var t = 9; t < 11; t++) {
      var soma = 0;
      for (var i = 0; i < t; i++) {
        soma += d[i] * (t + 1 - i);
      }
      final dv = (soma * 10) % 11 % 10;
      if (dv != d[t]) return false;
    }
    return true;
  }

  static bool emailValido(String s) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s.trim());
}
