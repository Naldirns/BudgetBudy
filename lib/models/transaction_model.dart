enum TransactionType { gave, got }

class TransactionModel {
  final int? id;
  final int partyId;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.partyId,
    required this.amount,
    required this.type,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyId': partyId,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      partyId: map['partyId'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: (map['type'] as String) == 'gave'
          ? TransactionType.gave
          : TransactionType.got,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String,
    );
  }
}



