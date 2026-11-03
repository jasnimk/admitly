import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  applicationCreated,
  feePaid,
  feeSkipped,
  slotBooked,
  examCompleted,
  admissionCompleted;

  String get label => switch (this) {
        applicationCreated => 'Application Created',
        feePaid            => 'Fee Paid',
        feeSkipped         => 'Fee Skipped',
        slotBooked         => 'Slot Booked',
        examCompleted      => 'Exam Completed',
        admissionCompleted => 'Admission Completed',
      };
}

enum Gender { male, female, other }

class StudentEntity extends Equatable {
  const StudentEntity({
    required this.id,
    required this.parentId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.previousSchool,
    required this.applyingGrade,
    required this.status,
    required this.createdAt,
    this.paymentStatus,
    this.examSlotId,
    this.examScore,
    this.assignedCourse,
  });

  final String id;
  final String parentId;
  final String name;
  final DateTime dateOfBirth;
  final Gender gender;
  final String previousSchool;
  final String applyingGrade;
  final ApplicationStatus status;
  final DateTime createdAt;
  final String? paymentStatus;
  final String? examSlotId;
  final int? examScore;
  final String? assignedCourse;

  bool get isEditable => status == ApplicationStatus.applicationCreated ||
      status == ApplicationStatus.feePaid ||
      status == ApplicationStatus.feeSkipped;

  @override
  List<Object?> get props => [
        id, parentId, name, dateOfBirth, gender, previousSchool,
        applyingGrade, status, createdAt, paymentStatus,
        examSlotId, examScore, assignedCourse,
      ];
}
