import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The 8 emergency types selectable in the Report Emergency screen.
enum EmergencyType {
  accident,
  fire,
  medical,
  flood,
  quake,
  robbery,
  assault,
  other,
}

extension EmergencyTypeX on EmergencyType {
  String get label {
    switch (this) {
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.flood:
        return 'Flood';
      case EmergencyType.quake:
        return 'Quake';
      case EmergencyType.robbery:
        return 'Robbery';
      case EmergencyType.assault:
        return 'Assault';
      case EmergencyType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyType.accident:
        return Icons.car_crash_outlined;
      case EmergencyType.fire:
        return Icons.local_fire_department_outlined;
      case EmergencyType.medical:
        return Icons.medical_services_outlined;
      case EmergencyType.flood:
        return Icons.house_outlined; // closest match w/ wave overlay below
      case EmergencyType.quake:
        return Icons.home_outlined; // overlaid w/ bolt below for quake feel
      case EmergencyType.robbery:
        return Icons.people_outline;
      case EmergencyType.assault:
        return Icons.gpp_bad_outlined;
      case EmergencyType.other:
        return Icons.more_horiz_rounded;
    }
  }
}

/// 4-column grid of emergency type cards (icon + label), matching the
/// red-filled-circle-with-checkmark selected state and grey outlined
/// unselected state from the Figma design. Selecting [EmergencyType.other]
/// reveals an inline text field for a custom description.
class EmergencyTypeGrid extends StatelessWidget {
  final EmergencyType? selected;
  final ValueChanged<EmergencyType> onSelected;
  final TextEditingController otherController;

  const EmergencyTypeGrid({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.otherController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 22,
          crossAxisSpacing: 8,
          childAspectRatio: 0.78,
          children: EmergencyType.values.map((type) {
            final isSelected = selected == type;
            return _TypeCell(
              type: type,
              isSelected: isSelected,
              onTap: () => onSelected(type),
            );
          }).toList(),
        ),
        if (selected == EmergencyType.other) ...[
          const SizedBox(height: 16),
          TextField(
            controller: otherController,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'Describe the emergency',
              hintStyle: AppTextStyles.hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.primaryRed),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.primaryRed),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide:
                    const BorderSide(color: AppColors.primaryRed, width: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeCell extends StatelessWidget {
  final EmergencyType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCell({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryRed : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.borderGrey,
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  type.icon,
                  size: 26,
                  color: isSelected ? Colors.white : AppColors.borderGrey,
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            type.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.textDark : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}