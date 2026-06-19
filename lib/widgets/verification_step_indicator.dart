import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A 3-step horizontal stepper matching the Figma design:
/// - Completed steps  → filled red circle with a white checkmark
/// - Active step      → outlined red circle with the step number in red
/// - Future steps     → outlined grey circle with the step number in grey
/// Connected by lines that turn red once the step before them is complete.
class VerificationStepIndicator extends StatelessWidget {
  final int currentStep; // 1-based: 1, 2, or 3
  final int totalSteps;

  const VerificationStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        // Even indices → step circles; odd indices → connector lines
        if (i.isEven) {
          final step = i ~/ 2 + 1;
          return _buildStepCircle(step);
        } else {
          // Line between step i÷2 and step i÷2+1
          final leftStep = i ~/ 2 + 1;
          final lineIsComplete = currentStep > leftStep;
          return Expanded(
            child: Container(
              height: 2,
              color: lineIsComplete ? AppColors.primaryRed : AppColors.borderGrey,
            ),
          );
        }
      }),
    );
  }

  Widget _buildStepCircle(int step) {
    final bool isCompleted = currentStep > step;
    final bool isActive = currentStep == step;

    if (isCompleted) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.primaryRed,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 22),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primaryRed : AppColors.borderGrey,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        step.toString().padLeft(2, '0'),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.primaryRed : AppColors.hintGrey,
        ),
      ),
    );
  }
}