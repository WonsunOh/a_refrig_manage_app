class Product {
  int? id;
  String? refrigName;
  String? storageName;
  String? containerName; // [추가] 제품이 보관된 용기 이름
  String? foodName;
  String? category;
  String? iconAdress;
  DateTime? inputDate;
  DateTime? useDate;
  String? amount;
  String? useAmount;
  String? unit;
  String? memo;
  bool isLongTermStorage; // ✅ [추가] 장기보관 여부 필드

  Product({
    this.id,
    this.refrigName,
    this.storageName,
    this.containerName,
    this.foodName,
    this.category,
    this.iconAdress,
    this.inputDate,
    this.useDate,
    this.amount,
    this.useAmount,
    this.unit,
    this.memo,
    this.isLongTermStorage = false, 
  });

  // [추가] copyWith 메소드
  Product copyWith({
    int? id,
    String? refrigName,
    String? storageName,
    String? containerName,
    String? foodName,
    String? category,
    String? iconAdress,
    DateTime? inputDate,
    DateTime? useDate,
    String? amount,
    String? useAmount,
    String? unit,
    String? memo,
    bool? isLongTermStorage,
  }) {
    return Product(
      id: id ?? this.id,
      refrigName: refrigName ?? this.refrigName,
      storageName: storageName ?? this.storageName,
      containerName: containerName ?? this.containerName,
      foodName: foodName ?? this.foodName,
      category: category ?? this.category,  
      iconAdress: iconAdress ?? this.iconAdress,
      inputDate: inputDate ?? this.inputDate,
      useDate: useDate ?? this.useDate,
      amount: amount ?? this.amount,
      useAmount: useAmount ?? this.useAmount,
      unit: unit ?? this.unit,
      memo: memo ?? this.memo,
      isLongTermStorage: isLongTermStorage ?? this.isLongTermStorage,
    );
  }

  factory Product.fromMap(Map<dynamic, dynamic> json) {
    return Product(
      id: json['id'],
      refrigName: json['refrigName'],
      storageName: json['storageName'],
      containerName: json['containerName'],
      foodName: json['foodName'],
      category: json['category'],
      iconAdress: json['iconAdress'],
      inputDate: DateTime.parse(json['inputDate']),
      useDate: DateTime.parse(json['useDate']),
      amount: json['amount'],
      useAmount: json['useAmount'],
      unit: json['unit'],
      memo: json['memo'],
      // DB에는 0 또는 1로 저장되므로, 불러올 때 boolean으로 변환
      isLongTermStorage: json['isLongTermStorage'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'refrigName': refrigName,
      'storageName': storageName,
      'containerName': containerName,
      'foodName': foodName,
      'category': category,
      'iconAdress': iconAdress,
      'inputDate': inputDate?.toIso8601String(),
      'useDate': useDate?.toIso8601String(),
      'amount': amount,
      'useAmount': useAmount,
      'unit': unit,
      'memo': memo,
      'isLongTermStorage': isLongTermStorage,
    };
  }
}
