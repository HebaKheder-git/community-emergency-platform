import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Six individual boxes for entering an OTP code. Auto-advances focus as
/// each digit is typed and auto-backs-up on delete, matching the behavior
/// implied by the Figma screens (empty grey boxes -> active red boxes).
class OtpInputBoxes extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputBoxes({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputBoxes> createState() => OtpInputBoxesState();
}

class OtpInputBoxesState extends State<OtpInputBoxes> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Call this externally (e.g. from a "Resend" handler) to clear all boxes.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    setState(() {});
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  void _onChangedAt(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged?.call(_currentCode);
    if (_currentCode.length == widget.length) {
      widget.onCompleted(_currentCode);
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final bool isActive = _controllers[index].text.isNotEmpty ||
            _focusNodes[index].hasFocus;
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 20, color: AppColors.textDark),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isActive ? AppColors.primaryRed : AppColors.borderGrey,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isActive ? AppColors.primaryRed : AppColors.borderGrey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
              ),
            ),
            onChanged: (value) => _onChangedAt(index, value),
          ),
        );
      }),
    );
  }
}