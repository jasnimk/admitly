import 'package:admitly/core/utils/app_logger.dart';
import 'package:admitly/features/student/data/models/student_model.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StudentRemoteDataSource {
  Future<StudentModel> createStudent(StudentEntity student);
  Future<StudentModel> updateStudent(StudentEntity student);
  Future<List<StudentModel>> getStudentsByParent(String parentId);
  Future<List<StudentModel>> getAllStudents();
  Future<StudentModel> getStudentById(String id);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  StudentRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference get _col => _firestore.collection('students');

  @override
  Future<StudentModel> createStudent(StudentEntity student) async {
    final doc = _col.doc();
    final model = StudentModel(
      id: doc.id,
      parentId: student.parentId,
      name: student.name,
      dateOfBirth: student.dateOfBirth,
      gender: student.gender,
      previousSchool: student.previousSchool,
      applyingGrade: student.applyingGrade,
      status: ApplicationStatus.applicationCreated,
      createdAt: DateTime.now(),
    );
    await doc.set(model.toMap());
    appLogger.i('Student created: ${doc.id}');
    return model;
  }

  @override
  Future<StudentModel> updateStudent(StudentEntity student) async {
    final model = StudentModel(
      id: student.id,
      parentId: student.parentId,
      name: student.name,
      dateOfBirth: student.dateOfBirth,
      gender: student.gender,
      previousSchool: student.previousSchool,
      applyingGrade: student.applyingGrade,
      status: student.status,
      createdAt: student.createdAt,
      paymentStatus: student.paymentStatus,
      examSlotId: student.examSlotId,
      examScore: student.examScore,
      assignedCourse: student.assignedCourse,
    );
    await _col.doc(student.id).update(model.toMap());
    appLogger.i('Student updated: ${student.id}');
    return model;
  }

  @override
  Future<List<StudentModel>> getStudentsByParent(String parentId) async {
    final snap = await _col
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => StudentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StudentModel>> getAllStudents() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => StudentModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudentModel> getStudentById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) throw Exception('Student not found');
    return StudentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
