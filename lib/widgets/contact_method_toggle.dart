import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ContactMethod { email, phone }

/// The two-pill toggle ("Email" / "Phone") that switches the input field
/// below it between email and phone modes, exactly as in the Figma design.
class ContactMethodToggle extends StatelessWidget {
  final ContactMethod selected;
  final ValueChanged<ContactMethod> onChanged;

  const ContactMethodToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPill(
          label: 'Email',
          icon: Icons.email_outlined,
          method: ContactMethod.email,
        ),
        const SizedBox(width: 12),
        _buildPill(
          label: 'Phone',
          icon: Icons.phone_outlined,
          method: ContactMethod.phone,
        ),
      ],
    );
  }

  Widget _buildPill({
    required String label,
    required IconData icon,
    required ContactMethod method,
  }) {
    final bool isActive = selected == method;
    return GestureDetector(
      onTap: () => onChanged(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryRed : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : AppColors.textGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}