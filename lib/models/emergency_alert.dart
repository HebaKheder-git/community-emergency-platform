/// Status of an emergency alert as it relates to the current user.
enum AlertStatus {
  /// Still open — user can tap "View" and volunteer.
  open,

  /// User (or the situation) marked it resolved — shows the green
  /// "Finished" pill instead of "View".
  finished,
}

/// Simple value object backing both [NotificationsScreen] and
/// [EmergencyAlertDetailScreen]. In the real app this will likely be
/// replaced/wrapped by a Qubit state model fed from the backend, but the
/// shape (fields below) should stay the same so the UI doesn't need to
/// change when that wiring happens.
class EmergencyAlert {
  final String id;
  final String title; // e.g. "Road Accident"
  final String summary; // short line shown in the list
  final String description; // long paragraph shown in the detail screen
  final String reportedBy;
  final int volunteersJoined;
  final int volunteersNeeded;
  final String severity; // e.g. "Severe"
  final String locationLabel; // e.g. "Kothrud, Pune, 411038"
  final DateTime date;
  final AlertStatus status;

  const EmergencyAlert({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.reportedBy,
    required this.volunteersJoined,
    required this.volunteersNeeded,
    required this.severity,
    required this.locationLabel,
    required this.date,
    this.status = AlertStatus.open,
  });

  String get volunteerFraction => '$volunteersJoined/$volunteersNeeded';

  /// Matches the "12/3/2026" style date formatting in the Figma — no
  /// intl package dependency needed for this simple d/M/yyyy format.
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}

/// Temporary mock data so the screen is fully scrollable/interactive
/// without backend wiring yet. Swap this out once Qubit is connected.
final List<EmergencyAlert> mockEmergencyAlerts = [
  EmergencyAlert(
    id: '1',
    title: 'Road Accident',
    summary: 'The incident between two cars on SA13Rd.',
    description:
        'The incident involved the vehicle MH 41 AK 6543, which was '
        'involved in a collision between a car and a motorcycle. The '
        'accident resulted in a serious head injury for the biker. Urgent '
        'emergency services are needed at this location.',
    reportedBy: 'Helin Oston',
    volunteersJoined: 8,
    volunteersNeeded: 20,
    severity: 'Severe',
    locationLabel: 'Kothrud, Pune, 411038',
    date: DateTime(2026, 3, 12),
  ),
  EmergencyAlert(
    id: '2',
    title: 'Road Accident',
    summary: 'The incident between two cars on SA13Rd.',
    description:
        'The incident involved the vehicle MH 41 AK 6543, which was '
        'involved in a collision between a car and a motorcycle. The '
        'accident resulted in a serious head injury for the biker. Urgent '
        'emergency services are needed at this location.',
    reportedBy: 'Helin Oston',
    volunteersJoined: 8,
    volunteersNeeded: 20,
    severity: 'Severe',
    locationLabel: 'Kothrud, Pune, 411038',
    date: DateTime(2026, 3, 12),
  ),
  EmergencyAlert(
    id: '3',
    title: 'Road Accident',
    summary: 'The incident between two cars on SA13Rd.',
    description:
        'The incident involved the vehicle MH 41 AK 6543, which was '
        'involved in a collision between a car and a motorcycle. The '
        'accident resulted in a serious head injury for the biker. Urgent '
        'emergency services are needed at this location.',
    reportedBy: 'Helin Oston',
    volunteersJoined: 8,
    volunteersNeeded: 20,
    severity: 'Severe',
    locationLabel: 'Kothrud, Pune, 411038',
    date: DateTime(2026, 3, 12),
  ),
  EmergencyAlert(
    id: '4',
    title: 'Road Accident',
    summary: 'The incident between two cars on SA13Rd.',
    description:
        'The incident involved the vehicle MH 41 AK 6543, which was '
        'involved in a collision between a car and a motorcycle. The '
        'accident resulted in a serious head injury for the biker. Urgent '
        'emergency services are needed at this location.',
    reportedBy: 'Helin Oston',
    volunteersJoined: 8,
    volunteersNeeded: 20,
    severity: 'Severe',
    locationLabel: 'Kothrud, Pune, 411038',
    date: DateTime(2026, 3, 12),
  ),
  EmergencyAlert(
    id: '5',
    title: 'Road Accident',
    summary: 'The incident between two cars on SA13Rd.',
    description:
        'The incident involved the vehicle MH 41 AK 6543, which was '
        'involved in a collision between a car and a motorcycle. The '
        'accident resulted in a serious head injury for the biker. Urgent '
        'emergency services are needed at this location.',
    reportedBy: 'Helin Oston',
    volunteersJoined: 8,
    volunteersNeeded: 20,
    severity: 'Severe',
    locationLabel: 'Kothrud, Pune, 411038',
    date: DateTime(2026, 2, 3),
    status: AlertStatus.finished,
  ),
];