import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamSlotModel extends ExamSlotEntity {
  const ExamSlotModel({
    required super.id,
    required super.date,
    required super.timeLabel,
    required super.venue,
    required super.capacity,
    required super.bookedCount,
  });

  factory ExamSlotModel.fromMap(String id, Map<String, dynamic> map) =>
      ExamSlotModel(
        id: id,
        date: (map['date'] as Timestamp).toDate(),
        timeLabel: map['timeLabel'] as String,
        venue: map['venue'] as String,
        capacity: map['capacity'] as int,
        bookedCount: map['bookedCount'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'timeLabel': timeLabel,
        'venue': venue,
        'capacity': capacity,
        'bookedCount': bookedCount,
      };
}
