import 'package:flutter/material.dart';
import 'package:tandem/core/l10n/l10n_extension.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/theme_context.dart';

/// Home, Tasks, Progress, Team. The current tab has a mint pill behind its icon.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentIndex, required this.onSelect, super.key});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(IconData, String)>[
      (Icons.home_outlined, l10n.common_navHome),
      (Icons.checklist_rounded, l10n.common_navTasks),
      (Icons.bar_chart_rounded, l10n.common_navProgress),
      (Icons.group_outlined, l10n.common_navTeam),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.paper2,
        border: Border(top: BorderSide(color: AppColors.rule)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: items[i].$1,
                    label: items[i].$2,
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accentDeep : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 52,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentSoft : null,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 2),
              Text(label, style: context.type.bodyMedium(size: context.type.xs, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
