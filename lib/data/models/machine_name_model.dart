class MachineName {
  int? id;
  String? machineName;
  String? refrigIcon;
  String? machineType;
   // [추가] UI 표시용 필드
  int? totalItemCount;
  int? expiringItemCount;

 MachineName({
    this.id,
    this.machineName,
    this.refrigIcon,
    this.machineType,
    // [추가] 생성자에도 추가
    this.totalItemCount,
    this.expiringItemCount,
  });

  // [추가] 객체 복사를 위한 copyWith 메소드
  MachineName copyWith({
    int? id,
    String? machineName,
    String? refrigIcon,
    String? machineType,
    int? totalItemCount,
    int? expiringItemCount,
  }) {
    return MachineName(
      id: id ?? this.id,
      machineName: machineName ?? this.machineName,
      refrigIcon: refrigIcon ?? this.refrigIcon,
      machineType: machineType ?? this.machineType,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      expiringItemCount: expiringItemCount ?? this.expiringItemCount,
    );
  }

  factory MachineName.fromMap(Map<dynamic, dynamic> json) {
    return MachineName(
      id: json['id'],
      machineName: json['machineName'],
      refrigIcon: json['refrigIcon'],
      machineType: json['machineType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineName': machineName,
      'refrigIcon': refrigIcon,
      'machineType': machineType,
    };
  }
}