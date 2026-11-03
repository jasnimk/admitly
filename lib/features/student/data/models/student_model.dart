import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.parentId,
    required super.name,
    required super.dateOfBirth,
    required super.gender,
    required super.previousSchool,
    required super.applyingGrade,
    required super.status,
    required super.createdAt,
    super.paymentStatus,
    super.examSlotId,
    super.examScore,
    super.assignedCourse,
  });

  factory StudentModel.fromMap(String id, Map<String, dynamic> map) {
    return StudentModel(
      id: id,
      parentId: map['parentId'] as String,
      name: map['name'] as String,
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      gender: Gender.values.firstWhere(
        (g) => g.name == (map['gender'] as String? ?? 'male'),
        orElse: () => Gender.male,
      ),
      previousSchool: map['previousSchool'] as String? ?? '',
      applyingGrade: map['applyingGrade'] as String? ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'applicationCreated'),
        orElse: () => ApplicationStatus.applicationCreated,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paymentStatus: map['paymentStatus'] as String?,
      examSlotId: map['examSlotId'] as String?,
      examScore: map['examScore'] as int?,
      assignedCourse: map['assignedCourse'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'parentId': parentId,
        'name': name,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'gender': gender.name,
        'previousSchool': previousSchool,
        'applyingGrade': applyingGrade,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (examSlotId != null) 'examSlotId': examSlotId,
        if (examScore != null) 'examScore': examScore,
        if (assignedCourse != null) 'assignedCourse': assignedCourse,
      };
}
