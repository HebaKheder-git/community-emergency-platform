// lib/services/verification_status.dart
//
// TEMPORARY placeholder for account-verification state — stands in for the
// Qubit (Cubit) that will eventually own this once the backend is wired up.
// Keeping it as a single ValueNotifier means every screen that needs to
// know "is this user verified?" reads from the same place, so swapping it
// for a real Cubit later is a one-file change (just re-point the
// ValueListenableBuilder calls at the Cubit's state stream / BlocBuilder).

import 'package:flutter/foundation.dart';

class VerificationStatus {
  VerificationStatus._();
  static final VerificationStatus instance = VerificationStatus._();

  /// true  -> user completed account verification, full access everywhere.
  /// false -> user hasn't verified yet (default) — Home, Notifications,
  ///          Community Chat and Service Providers show the locked view.
  ///          Marketplaces is intentionally excluded from this gate.
  final ValueNotifier<bool> isVerified = ValueNotifier<bool>(false);

  void markVerified() => isVerified.value = true;

  void markUnverified() => isVerified.value = false;
}