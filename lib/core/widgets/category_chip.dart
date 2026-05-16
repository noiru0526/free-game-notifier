import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Genre/platform category chip
class CategoryChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? _colorForLabel(label);
    final bgColor = selected
        ? chipColor.withOpacity(0.25)
        : chipColor.withOpacity(0.12);
    final borderColor = selected
        ? chipColor.withOpacity(0.7)
        : chipColor.withOpacity(0.3);
    final textColor = selected ? chipColor : chipColor.withOpacity(0.85);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs2,
        ),
        constraints: const BoxConstraints(minHeight: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: textColor,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  static Color _colorForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('action') || lower.contains('アクション')) return AppColors.genreAction;
    if (lower.contains('rpg'))                return AppColors.genreRPG;
    if (lower.contains('indie') || lower.contains('インディー')) return AppColors.genreIndie;
    if (lower.contains('shoot') || lower.contains('fps') || lower.contains('シューター')) return AppColors.genreShooter;
    if (lower.contains('strateg') || lower.contains('ストラテジー')) return AppColors.genreStrategy;
    if (lower.contains('advent') || lower.contains('アドベンチャー')) return AppColors.genreAdvent;
    if (lower.contains('horror') || lower.contains('ホラー')) return AppColors.genreHorror;
    if (lower.contains('epic'))   return AppColors.interactivePrimary;
    if (lower.contains('steam'))  return AppColors.interactiveAccent;
    if (lower.contains('gog'))    return AppColors.platformGOG;
    return AppColors.genreOther;
  }
}

/// Row of filter chips for genre selection
class CategoryChipRow extends StatefulWidget {
  final List<String> categories;
  final List<String> selected;
  final ValueChanged<List<String>>? onChanged;

  const CategoryChipRow({
    super.key,
    required this.categories,
    this.selected = const [],
    this.onChanged,
  });

  @override
  State<CategoryChipRow> createState() => _CategoryChipRowState();
}

class _CategoryChipRowState extends State<CategoryChipRow> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.of(widget.selected);
  }

  void _toggle(String cat) {
    setState(() {
      if (_selected.contains(cat)) _selected.remove(cat);
      else _selected.add(cat);
    });
    widget.onChanged?.call(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (_, i) {
          final cat = widget.categories[i];
          return CategoryChip(
            label: cat,
            selected: _selected.contains(cat),
            onTap: () => _toggle(cat),
          );
        },
      ),
    );
  }
}
