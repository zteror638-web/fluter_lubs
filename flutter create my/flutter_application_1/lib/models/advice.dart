class Advice {
  final int id;
  final String advice;
  bool isUsed;
  DateTime? dateSaved;

  Advice({
    required this.id,
    required this.advice,
    this.isUsed = false,
    this.dateSaved,
  });

  factory Advice.fromJson(Map<String, dynamic> json) {
    return Advice(
      id: json['slip']['id'],
      advice: json['slip']['advice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advice': advice,
      'isUsed': isUsed ? 1 : 0,
      'dateSaved': dateSaved?.toIso8601String(),
    };
  }

  factory Advice.fromDatabase(Map<String, dynamic> json) {
    return Advice(
      id: json['id'],
      advice: json['advice'],
      isUsed: json['isUsed'] == 1,
      dateSaved: json['dateSaved'] != null 
          ? DateTime.parse(json['dateSaved']) 
          : null,
    );
  }
}