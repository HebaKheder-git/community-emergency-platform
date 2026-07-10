// lib/models/emergency_group.dart
//
// Models for the "Emergency — Membership (Trusted)" flow: searching for a
// nearby group (POST /emergency/groups/join) and confirming a join
// (official / pending / new-pending).
//
// ⚠️ ASSUMPTION FLAG: the Postman collection's test scripts only prove that
// each item in official_groups[] / pending_groups[] has an `id`
// (`d.official_groups[0].id`). The optional display fields below
// (name / address / distance_km / members_count) are my best guess at what
// a group "card" needs and are parsed defensively — if a key is missing or
// named differently on the real backend, the UI falls back to
// "Group #<id>" instead of crashing. Send me one real sample response from
// Search Groups and I'll tighten these up to match exactly.

abstract class GroupSummaryBase {
  int get id;
  String get displayName;
  String? get subtitle;
}

class OfficialGroupSummary implements GroupSummaryBase {
  @override
  final int id;
  final String? name;
  final String? address;
  final double? distanceKm;
  final int? membersCount;

  const OfficialGroupSummary({
    required this.id,
    this.name,
    this.address,
    this.distanceKm,
    this.membersCount,
  });

  factory OfficialGroupSummary.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v == null ? null : double.tryParse(v.toString());
    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

    return OfficialGroupSummary(
      id: toInt(json['id']) ?? 0,
      name: json['name'] as String?,
      address: (json['address'] ?? json['city'] ?? json['location_name'])
          as String?,
      distanceKm: toDouble(json['distance_km'] ?? json['distance']),
      membersCount: toInt(json['members_count'] ?? json['members']),
    );
  }

  @override
  String get displayName => name ?? 'Group #$id';

  @override
  String? get subtitle {
    final parts = <String>[
      if (address != null) address!,
      if (distanceKm != null) '${distanceKm!.toStringAsFixed(1)} km away',
      if (membersCount != null) '$membersCount members',
    ];
    return parts.isEmpty ? null : parts.join(' • ');
  }
}

class PendingGroupSummary implements GroupSummaryBase {
  @override
  final int id;
  final String? name;
  final int? membersCount;

  const PendingGroupSummary({
    required this.id,
    this.name,
    this.membersCount,
  });

  factory PendingGroupSummary.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
    return PendingGroupSummary(
      id: toInt(json['id']) ?? 0,
      name: json['name'] as String?,
      membersCount: toInt(json['members_count'] ?? json['members']),
    );
  }

  @override
  String get displayName => name ?? 'Pending group #$id';

  @override
  String? get subtitle =>
      membersCount != null ? '$membersCount members so far' : null;
}

enum GroupSearchScenario { officialAvailable, pendingOnly, none }

/// Response of POST /emergency/groups/join.
class GroupSearchResult {
  final GroupSearchScenario scenario;
  final List<OfficialGroupSummary> officialGroups;
  final List<PendingGroupSummary> pendingGroups;

  const GroupSearchResult({
    required this.scenario,
    this.officialGroups = const [],
    this.pendingGroups = const [],
  });

  factory GroupSearchResult.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final official = (root['official_groups'] as List? ?? [])
        .map((e) => OfficialGroupSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final pending = (root['pending_groups'] as List? ?? [])
        .map((e) => PendingGroupSummary.fromJson(e as Map<String, dynamic>))
        .toList();

    GroupSearchScenario scenario;
    switch (root['scenario'] as String? ?? 'none') {
      case 'official_available':
        scenario = GroupSearchScenario.officialAvailable;
        break;
      case 'pending_only':
        scenario = GroupSearchScenario.pendingOnly;
        break;
      default:
        scenario = GroupSearchScenario.none;
    }

    return GroupSearchResult(
      scenario: scenario,
      officialGroups: official,
      pendingGroups: pending,
    );
  }
}

/// Response shared by all three "confirm" endpoints:
///   POST /emergency/groups/{group_id}/join/confirm
///   POST /emergency/pending-groups/{pending_group_id}/join/confirm
///   POST /emergency/pending-groups/join/confirm
class JoinConfirmationResult {
  final String status; // "joined" | "already_member" | ...
  final int? groupId;
  final int? chatId;
  final bool chatAccess;

  const JoinConfirmationResult({
    required this.status,
    this.groupId,
    this.chatId,
    this.chatAccess = false,
  });

  factory JoinConfirmationResult.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

    return JoinConfirmationResult(
      status: root['status'] as String? ?? 'joined',
      groupId: toInt(root['group_id']),
      chatId: toInt(root['chat_id']),
      chatAccess: root['chat_access'] == true,
    );
  }

  /// Pending-group confirms return chat_id: null until an admin approves.
  bool get isPendingApproval => chatId == null;
}
/// Response of GET /emergency/my-group.
///
/// ⚠️ ASSUMPTION FLAG: no sample response in the collection for this
/// endpoint (empty "response": []). Postman description says it "Returns
/// group + membership + chat_id (= group.id)", so I'm assuming:
/// { "data": { "chat_id": 4, "group": { "id": 4, "name": "..." } } }
/// Parsed defensively — send a real sample and I'll tighten this.
class HomeGroupInfo {
  final int? chatId;
  final int? groupId;
  final String? groupName;

  const HomeGroupInfo({this.chatId, this.groupId, this.groupName});

  factory HomeGroupInfo.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

    final group = (root['group'] is Map<String, dynamic>)
        ? root['group'] as Map<String, dynamic>
        : null;

    return HomeGroupInfo(
      chatId: toInt(root['chat_id']) ?? toInt(group?['id']),
      groupId: toInt(group?['id']) ?? toInt(root['group_id']),
      groupName: group?['name'] as String?,
    );
  }

  bool get hasChatAccess => chatId != null;
}