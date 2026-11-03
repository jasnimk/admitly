import 'package:admitly/features/exam_slot/data/models/exam_slot_model.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ExamSlotRemoteDataSource {
  Future<List<ExamSlotModel>> getAvailableSlots();
  Future<void> bookSlot({required String slotId, required String studentId});
}

class ExamSlotRemoteDataSourceImpl implements ExamSlotRemoteDataSource {
  const ExamSlotRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<List<ExamSlotModel>> getAvailableSlots() async {
    final snap = await _firestore
        .collection('examSlots')
        .orderBy('date')
        .get();
    return snap.docs
        .map((d) => ExamSlotModel.fromMap(d.id, d.data()))
        .where((s) => s.isAvailable)
        .toList();
  }

  @override
  Future<void> bookSlot({
    required String slotId,
    required String studentId,
  }) async {
    final slotRef = _firestore.collection('examSlots').doc(slotId);
    final studentRef = _firestore.collection('students').doc(studentId);

    await _firestore.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) throw Exception('Slot not found');

      final slot = ExamSlotModel.fromMap(slotSnap.id, slotSnap.data()!);
      if (!slot.isAvailable) throw Exception('Slot is fully booked');

      tx.update(slotRef, {'bookedCount': FieldValue.increment(1)});
      tx.update(studentRef, {
        'examSlotId': slotId,
        'status': ApplicationStatus.slotBooked.name,
      });
    });
  }
}
