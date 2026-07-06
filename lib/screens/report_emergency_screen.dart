import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/emergency_type_grid.dart';
import '../widgets/severity_selector.dart';
import '../widgets/primary_button.dart';
import 'location_picker_sheet.dart';
import 'emergency_submitted_dialog.dart';
import 'home_screen.dart';

/// "Report Emergency" screen — shown after the SOS button is tapped and
/// confirmed on [HomeScreen]. Lets the user pick an emergency type
/// (with a free-text field for "Other"), confirm/edit their location via
/// the [LocationPickerSheet], optionally set a severity level, add a note,
/// and submit the report.
class ReportEmergencyScreen extends StatefulWidget {
  const ReportEmergencyScreen({super.key});

  @override
  State<ReportEmergencyScreen> createState() => _ReportEmergencyScreenState();
}

class _ReportEmergencyScreenState extends State<ReportEmergencyScreen> {
  EmergencyType? _selectedType = EmergencyType.accident;
  SeverityLevel? _selectedSeverity;

  EmergencyLocation _location = const EmergencyLocation(
    country: 'Kothrud',
    city: 'Pune',
    state: '411038',
  );

  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool get _canSubmit {
    if (_selectedType == null) return false;
    if (_selectedType == EmergencyType.other &&
        _otherController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _otherController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await showLocationPickerSheet(context, initial: _location);
    if (result != null) {
      setState(() => _location = result);
    }
  }

  Future<void> _submitReport() async {
    if (!_canSubmit) return;

    // TODO: send the report (type, custom description, location, severity,
    // note) to the backend / qubit state layer here.

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmergencySubmittedDialog(
        onGoHome: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textDark, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Report Emergency',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  20,
                  AppSpacing.screenPadding,
                  100,
                ),
                children: [
                  const _SectionLabel('Select Emergency type'),
                  const SizedBox(height: 14),
                  EmergencyTypeGrid(
                    selected: _selectedType,
                    onSelected: (type) => setState(() => _selectedType = type),
                    otherController: _otherController,
                  ),

                  const SizedBox(height: 28),
                  const _SectionLabel('Location'),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _openLocationPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.textDark, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _location.formatted,
                              style: AppTextStyles.inputText,
                            ),
                          ),
                          const Icon(Icons.edit_outlined,
                              color: AppColors.textDark, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const _SectionLabel('Severity Level', optionalSuffix: true),
                  const SizedBox(height: 14),
                  SeveritySelector(
                    selected: _selectedSeverity,
                    onChanged: (level) =>
                        setState(() => _selectedSeverity = level),
                  ),

                  const SizedBox(height: 28),
                  const _SectionLabel('Add a note', optionalSuffix: true),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 4,
                      minLines: 3,
                      style: AppTextStyles.inputText,
                      decoration: const InputDecoration(
                        hintText: 'e.g. there is three cars in the accident',
                        hintStyle: AppTextStyles.hint,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Submit button, pinned to the bottom ───────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 12),
          child: AnimatedBuilder(
            animation: _otherController,
            builder: (context, _) => PrimaryButton(
              label: 'Submit Report',
              enabled: _canSubmit,
              onPressed: _submitReport,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool optionalSuffix;

  const _SectionLabel(this.text, {this.optionalSuffix = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            if (optionalSuffix) ...[
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hintGrey,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        const Divider(color: AppColors.borderGrey, height: 1),
      ],
    );
  }
}