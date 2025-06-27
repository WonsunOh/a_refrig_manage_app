class Alam {
  int? id;
  String? alamDate;
  String? alamName;
  String? alamTime;

  Alam({this.id, this.alamDate, this.alamName, this.alamTime});

  factory Alam.fromMap(Map<dynamic, dynamic> json) {
    return Alam(
      id: json['id'],
      alamDate: json['alamDate'],
      alamName: json['alamName'],
      alamTime: json['alamTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alamDate': alamDate,
      'alamName': alamName,
      'alamTime': alamTime,
    };
  }
}