import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The four severity options shown on the Report Emergency screen.
enum SeverityLevel { mild, moderate, severe, critical }

class _SeverityMeta {
  final String label;
  final String subtitle;
  final Color color;
  final Color fillColor;

  const _SeverityMeta({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.fillColor,
  });
}

const Map<SeverityLevel, _SeverityMeta> _severityMeta = {
  SeverityLevel.mild: _SeverityMeta(
    label: 'Mild',
    subtitle: '5 responders',
    color: Color(0xFF2FAE54),
    fillColor: Color(0xFFCDEFD8),
  ),
  SeverityLevel.moderate: _SeverityMeta(
    label: 'Moderate',
    subtitle: '10 responders',
    color: Color(0xFFC9B400),
    fillColor: Color(0xFFFAF4C2),
  ),
  SeverityLevel.severe: _SeverityMeta(
    label: 'Severe',
    subtitle: '20 Responders',
    color: Color(0xFFE0791F),
    fillColor: Color(0xFFFBE2C7),
  ),
  SeverityLevel.critical: _SeverityMeta(
    label: 'Critical',
    subtitle: 'All nearby',
    color: AppColors.primaryRed,
    fillColor: Color(0xFFFAD2CF),
  ),
};

/// Horizontal row of 4 severity cards. Tapping a card toggles selection;
/// tapping the already-selected card deselects it again, since this field
/// is optional in the Figma design.
class SeveritySelector extends StatelessWidget {
  final SeverityLevel? selected;
  final ValueChanged<SeverityLevel?> onChanged;

  const SeveritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SeverityLevel.values.map((level) {
        final meta = _severityMeta[level]!;
        final isSelected = selected == level;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: level == SeverityLevel.critical ? 0 : 10,
            ),
            child: GestureDetector(
              onTap: () => onChanged(isSelected ? null : level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected ? meta.fillColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? meta.fillColor : AppColors.textDark,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meta.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: meta.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: meta.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}