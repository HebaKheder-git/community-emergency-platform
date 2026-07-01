// lib/widgets/filter_dropdown.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One half of the two-pill filter bar on [MarketplacesScreen]
/// ("Select product category" | "Select location"). Tapping it opens a
/// bottom sheet listing [options]; picking one updates the pill's label
/// and calls [onChanged]. "All" is always the default/first option.
class FilterDropdown<T> extends StatelessWidget {
  final String placeholder;
  final T? value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  /// Whether this pill sits on the left (rounds only its left corners
  /// and shows a trailing divider) or the right of the joined filter bar.
  final bool isFirst;

  const FilterDropdown({
    super.key,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.isFirst = false,
  });

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    placeholder,
                    style: AppTextStyles.fieldLabel,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.borderGrey,
                  ),
                  itemBuilder: (_, index) {
                    final option = options[index];
                    final isSelected = option == value;
                    return ListTile(
                      title: Text(
                        labelBuilder(option),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primaryRed
                              : AppColors.textDark,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.primaryRed, size: 20)
                          : null,
                      onTap: () {
                        onChanged(option);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = value != null ? labelBuilder(value as T) : placeholder;
    final isPlaceholder = value == null;

    return Expanded(
      child: InkWell(
        onTap: () => _openPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPlaceholder
                        ? AppColors.textGrey
                        : AppColors.textDark,
                    fontWeight:
                        isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.primaryRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}