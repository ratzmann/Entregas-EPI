import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/hc_theme.dart';

/// Logo oficial da HC. [sobreEscuro] usa a variante com texto claro.
class HcLogo extends StatelessWidget {
  final double altura;
  final bool sobreEscuro;

  const HcLogo({super.key, this.altura = 48, this.sobreEscuro = false});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    sobreEscuro
        ? 'assets/images/hc-assessoria-logo-dark.svg'
        : 'assets/images/hc-assessoria-logo.svg',
    height: altura,
    semanticsLabel: 'HC Assessoria de Segurança do Trabalho',
  );
}

/// Rótulo de seção em caixa-alta, como as placas de sinalização do site.
class Eyebrow extends StatelessWidget {
  final String texto;
  final Color? cor;
  const Eyebrow(this.texto, {super.key, this.cor});

  @override
  Widget build(BuildContext context) =>
      Text(texto.toUpperCase(), style: HcText.eyebrow.copyWith(color: cor));
}

class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? mensagem;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 48, color: HcColors.line),
          const SizedBox(height: 12),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (mensagem != null) ...[
            const SizedBox(height: 6),
            Text(
              mensagem!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
  );
}

/// Etiqueta pequena de status (ex.: "CA vencido", "Inativo").
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  const Etiqueta(this.texto, {super.key, required this.cor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: cor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      texto.toUpperCase(),
      style: TextStyle(
        fontFamily: HcFonts.label,
        fontWeight: FontWeight.w600,
        fontSize: 10.5,
        letterSpacing: 0.8,
        color: cor,
      ),
    ),
  );
}

class AvatarIniciais extends StatelessWidget {
  final String iniciais;
  final bool ativo;
  const AvatarIniciais(this.iniciais, {super.key, this.ativo = true});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 22,
    backgroundColor: ativo ? const Color(0xFFD5F1FD) : HcColors.surface2,
    child: Text(
      iniciais,
      style: TextStyle(
        fontFamily: HcFonts.headline,
        fontWeight: FontWeight.w700,
        color: ativo ? HcColors.brandInk : HcColors.inkMuted,
      ),
    ),
  );
}

void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? HcColors.danger : HcColors.navy,
      ),
    );
}
