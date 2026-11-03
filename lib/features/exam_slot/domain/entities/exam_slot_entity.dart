import 'package:equatable/equatable.dart';

class ExamSlotEntity extends Equatable {
  const ExamSlotEntity({
    required this.id,
    required this.date,
    required this.timeLabel,
    required this.venue,
    required this.capacity,
    required this.bookedCount,
  });

  final String id;
  final DateTime date;
  final String timeLabel;
  final String venue;
  final int capacity;
  final int bookedCount;

  bool get isAvailable => bookedCount < capacity;
  int get remaining => capacity - bookedCount;

  @override
  List<Object?> get props => [id, date, timeLabel, venue, capacity, bookedCount];
}
