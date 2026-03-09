class SosResponseDTO {
  final String sosId;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? address;
  final String? note;
  final DateTime? timestamp;
  final String? status;

  SosResponseDTO({
    required this.sosId,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.address,
    this.note,
    this.timestamp,
    this.status,
  });

  factory SosResponseDTO.fromJson(Map<String, dynamic> json) {
    return SosResponseDTO(
      sosId: json['sosId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      note: json['note'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'sosId': sosId,
    'latitude': latitude,
    'longitude': longitude,
    'phoneNumber': phoneNumber,
    'address': address,
    'note': note,
    'timestamp': timestamp?.toIso8601String(),
    'status': status,
  };
}
