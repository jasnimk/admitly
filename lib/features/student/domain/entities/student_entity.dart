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
    this.parentEmail,
    this.parentPhone,
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
  final String? parentEmail;
  final String? parentPhone;

  bool get isEditable => status == ApplicationStatus.applicationCreated ||
      status == ApplicationStatus.feePaid ||
      status == ApplicationStatus.feeSkipped;

  StudentEntity copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    String? previousSchool,
    String? applyingGrade,
    ApplicationStatus? status,
    DateTime? createdAt,
    String? paymentStatus,
    String? examSlotId,
    int? examScore,
    String? assignedCourse,
    String? parentEmail,
    String? parentPhone,
  }) =>
      StudentEntity(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        previousSchool: previousSchool ?? this.previousSchool,
        applyingGrade: applyingGrade ?? this.applyingGrade,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        examSlotId: examSlotId ?? this.examSlotId,
        examScore: examScore ?? this.examScore,
        assignedCourse: assignedCourse ?? this.assignedCourse,
        parentEmail: parentEmail ?? this.parentEmail,
        parentPhone: parentPhone ?? this.parentPhone,
      );

  @override
  List<Object?> get props => [
        id, parentId, name, dateOfBirth, gender, previousSchool,
        applyingGrade, status, createdAt, paymentStatus,
        examSlotId, examScore, assignedCourse, parentEmail, parentPhone,
      ];
}
