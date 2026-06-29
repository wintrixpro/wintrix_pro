class MatchModel {
  final String id;
  final String gameName;
  final String mapName;
  final String matchMode;
  final double entryFee;
  final double prize;
  final String status;
  final DateTime matchTime;
  final String roomId;
  final String roomPass;

  MatchModel({
    required this.id,
    required this.gameName,
    required this.mapName,
    required this.matchMode,
    required this.entryFee,
    required this.prize,
    required this.status,
    required this.matchTime,
    required this.roomId,
    required this.roomPass,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json, String id) {
    return MatchModel(
      id: id,
      gameName: json['game_name'] ?? 'BGMI',
      mapName: json['map_name'] ?? 'Erangel',
      matchMode: json['match_mode'] ?? 'Solo',
      entryFee: (json['entry_fee'] as num).toDouble(),
      prize: (json['prize'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      matchTime: DateTime.parse(json['match_time']),
      roomId: json['room_id'] ?? '',
      roomPass: json['room_pass'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_name': gameName,
      'map_name': mapName,
      'match_mode': matchMode,
      'entry_fee': entryFee,
      'prize': prize,
      'status': status,
      'match_time': matchTime.toIso8601String(),
      'room_id': roomId,
      'room_pass': roomPass,
    };
  }
}
