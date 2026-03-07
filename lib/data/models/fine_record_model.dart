class FineDataInfo {
  final int total;
  final int chuaXuPhat;
  final int daXuPhat;
  final String latest;

  FineDataInfo({
    required this.total,
    required this.chuaXuPhat,
    required this.daXuPhat,
    required this.latest,
  });

  factory FineDataInfo.fromJson(Map<String, dynamic> json) {
    return FineDataInfo(
      total: json['total'] as int? ?? 0,
      chuaXuPhat: json['chuaxuphat'] as int? ?? 0,
      daXuPhat: json['daxuphat'] as int? ?? 0,
      latest: json['latest'] as String? ?? '',
    );
  }
}

class FineRecord {
  final String bienKiemSoat;
  final String mauBien;
  final String loaiPhuongTien;
  final String hanhViViPham;
  final String thoiGianViPham;
  final String diaDiemViPham;
  final String trangThai;
  final String donViPhatHien;
  final List<String> noiGiaiQuyet;

  FineRecord({
    required this.bienKiemSoat,
    required this.mauBien,
    required this.loaiPhuongTien,
    required this.hanhViViPham,
    required this.thoiGianViPham,
    required this.diaDiemViPham,
    required this.trangThai,
    required this.donViPhatHien,
    required this.noiGiaiQuyet,
  });

  /// Đã xử phạt = đã nộp phạt / đã giải quyết
  bool get isPaid =>
      trangThai.toLowerCase().contains('đã xử phạt') ||
      trangThai.toLowerCase().contains('đã nộp');

  factory FineRecord.fromJson(Map<String, dynamic> json) {
    final rawNoi = json['Nơi giải quyết vụ việc'];
    final List<String> noiList = rawNoi is List
        ? rawNoi.map((e) => e.toString()).toList()
        : [];
    return FineRecord(
      bienKiemSoat: json['Biển kiểm soát'] as String? ?? '',
      mauBien: json['Màu biển'] as String? ?? '',
      loaiPhuongTien: json['Loại phương tiện'] as String? ?? '',
      hanhViViPham: json['Hành vi vi phạm'] as String? ?? '',
      thoiGianViPham: json['Thời gian vi phạm'] as String? ?? '',
      diaDiemViPham: json['Địa điểm vi phạm'] as String? ?? '',
      trangThai: json['Trạng thái'] as String? ?? '',
      donViPhatHien: json['Đơn vị phát hiện vi phạm'] as String? ?? '',
      noiGiaiQuyet: noiList,
    );
  }
}

class FineResponse {
  final int status;
  final String msg;
  final List<FineRecord> data;
  final FineDataInfo? dataInfo;

  FineResponse({
    required this.status,
    required this.msg,
    required this.data,
    this.dataInfo,
  });

  /// status 1 = found violations, status 2 = no violations
  bool get hasViolations => status == 1 && data.isNotEmpty;
  bool get notFound => status == 2;

  factory FineResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<FineRecord> records = rawData is List
        ? rawData
              .map((e) => FineRecord.fromJson(e as Map<String, dynamic>))
              .toList()
        : [];
    final rawInfo = json['data_info'];
    final FineDataInfo? info = rawInfo is Map<String, dynamic>
        ? FineDataInfo.fromJson(rawInfo)
        : null;
    return FineResponse(
      status: json['status'] as int? ?? 0,
      msg: json['msg'] as String? ?? '',
      data: records,
      dataInfo: info,
    );
  }
}
