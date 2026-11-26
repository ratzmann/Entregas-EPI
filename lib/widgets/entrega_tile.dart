import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../theme/hc_theme.dart';

class EntregaTile extends StatelessWidget {
  final Entrega entrega;
  final VoidCallback onTap;
  final bool mostrarColaborador;

  const EntregaTile({
    super.key,
    required this.entrega,
    required this.onTap,
    this.mostrarColaborador = true,
  });

  @override
  Widget build(BuildContext context) {
    final resumo = entrega.itens
        .map(
          (i) => i.quantidade > 1 ? '${i.quantidade}× ${i.epiNome}' : i.epiNome,
        )
        .join(', ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CaixaData(entrega.data),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mostrarColaborador
                          ? entrega.colaboradorNome
                          : '${entrega.totalItens} ${entrega.totalItens == 1 ? 'item' : 'itens'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      resumo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: HcColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaixaData extends StatelessWidget {
  final DateTime data;
  const _CaixaData(this.data);

  @override
  Widget build(BuildContext context) {
    final partes = Formatos.diaMes(data).split(' ');
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: HcColors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            partes[0],
            style: const TextStyle(
              fontFamily: HcFonts.headline,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.1,
            ),
          ),
          Text(
            partes[1].toUpperCase(),
            style: const TextStyle(
              fontFamily: HcFonts.label,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 1,
              color: HcColors.brandInk,
            ),
          ),
        ],
      ),
    );
  }
}
