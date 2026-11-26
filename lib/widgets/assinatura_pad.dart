import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show EagerGestureRecognizer;
import 'package:material_ui/material_ui.dart';

import '../theme/hc_theme.dart';

/// Guarda os traços desenhados e exporta a assinatura como PNG.
class AssinaturaController extends ChangeNotifier {
  final List<List<Offset>> _tracos = [];
  Size _tamanho = Size.zero;

  bool get vazia => _tracos.every((t) => t.isEmpty);

  void _iniciar(Offset p) {
    _tracos.add([p]);
    notifyListeners();
  }

  void _continuar(Offset p) {
    _tracos.last.add(p);
    notifyListeners();
  }

  void limpar() {
    _tracos.clear();
    notifyListeners();
  }

  Future<Uint8List?> exportarPng() async {
    if (vazia || _tamanho.isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Offset.zero & _tamanho, Paint()..color = Colors.white);
    _AssinaturaPainter(_tracos).paint(canvas, _tamanho);
    final img = await recorder.endRecording().toImage(
      _tamanho.width.ceil(),
      _tamanho.height.ceil(),
    );
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }
}

/// Área para o colaborador assinar o recebimento do EPI com o dedo.
class AssinaturaPad extends StatelessWidget {
  final AssinaturaController controller;
  const AssinaturaPad({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller._tamanho = Size(constraints.maxWidth, 170);
        return Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HcColors.line, width: 1.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            // O recognizer "eager" vence a disputa de gestos com a rolagem da
            // tela, então o traço desenha em vez de rolar o formulário.
            child: RawGestureDetector(
              gestures: {
                EagerGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      EagerGestureRecognizer
                    >(EagerGestureRecognizer.new, (_) {}),
              },
              child: Listener(
                onPointerDown: (e) => controller._iniciar(e.localPosition),
                onPointerMove: (e) => controller._continuar(e.localPosition),
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => Stack(
                    children: [
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 36,
                        child: Container(height: 1, color: HcColors.line),
                      ),
                      if (controller.vazia)
                        const Center(
                          child: Text(
                            'Assine aqui',
                            style: TextStyle(color: HcColors.inkMuted),
                          ),
                        ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _AssinaturaPainter(controller._tracos),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AssinaturaPainter extends CustomPainter {
  final List<List<Offset>> tracos;
  _AssinaturaPainter(this.tracos);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HcColors.navy
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final t in tracos) {
      if (t.length == 1) {
        canvas.drawCircle(t.first, 1.3, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(t.first.dx, t.first.dy);
      for (final p in t.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AssinaturaPainter oldDelegate) => true;
}
