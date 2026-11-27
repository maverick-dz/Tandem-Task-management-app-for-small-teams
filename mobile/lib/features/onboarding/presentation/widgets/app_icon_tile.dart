import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';

/// The app icon: a T built from two pieces, one for each owner. Drawn in code
/// (the same geometry as the exported icon) so that it stays sharp at any size.
class AppIconTile extends StatelessWidget {
  const AppIconTile({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.l10n.common_appIconLabel(context.l10n.appName),
      child: ExcludeSemantics(
        child: CustomPaint(size: Size.square(size), painter: const _IconPainter()),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 1024;
    canvas.save();
    canvas.scale(unit);
    final tile = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 1024, 1024),
      const Radius.circular(229),
    );
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.accent, AppColors.accentDeep],
        ).createShader(const Rect.fromLTWH(0, 0, 1024, 1024)),
    );

    // The mark is drawn 10% larger around the centre, as in the exported icon.
    canvas.translate(512, 512);
    canvas.scale(1.1);
    canvas.translate(-512, -512);

    RRect piece(double x, double y, double w, double h) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(88));

    final rim = Paint()..color = const Color(0x2E000000);
    canvas.drawRRect(piece(232, 290, 560, 176), rim);
    canvas.drawRRect(piece(424, 502, 176, 260), rim);
    canvas.drawRRect(piece(232, 276, 560, 176), Paint()..color = AppColors.paper);
    canvas.drawRRect(piece(424, 488, 176, 260), Paint()..color = AppColors.accentSoft);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(288, 292, 448, 16),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0x8CFFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
