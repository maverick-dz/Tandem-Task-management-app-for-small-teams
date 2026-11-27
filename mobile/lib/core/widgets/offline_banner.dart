import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/widgets/info_banner.dart';

/// Shown above lists while the phone is offline (screen 031 of the design).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      icon: Icons.wifi_off_rounded,
      text: context.l10n.common_offlineBanner,
    );
  }
}
