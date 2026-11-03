import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Seeds Firestore with dummy students and exam slots for development.
/// Call once — safe to call again (uses fixed doc IDs to avoid duplicates).
class DevSeeder {
  DevSeeder._();

  static final _db = FirebaseFirestore.instance;

  static Future<void> seed() async {
    assert(kDebugMode, 'DevSeeder must only run in debug mode');
    await Future.wait([_seedSlots(), _seedStudents()]);
    debugPrint('✅ DevSeeder: done');
  }

  static Future<void> _seedSlots() async {
    final slots = [
      {
        'id': 'slot_seed_1',
        'date': Timestamp.fromDate(DateTime(2026, 12, 10)),
        'timeLabel': '10:00 AM – 12:00 PM',
        'venue': 'Main Hall, Block A',
        'capacity': 30,
        'bookedCount': 3,
      },
      {
        'id': 'slot_seed_2',
        'date': Timestamp.fromDate(DateTime(2026, 12, 12)),
        'timeLabel': '2:00 PM – 4:00 PM',
        'venue': 'Conference Room, Block B',
        'capacity': 20,
        'bookedCount': 1,
      },
    ];
    for (final s in slots) {
      final id = s['id'] as String;
      await _db.collection('examSlots').doc(id).set({...s}..remove('id'));
    }
  }

  static Future<void> _seedStudents() async {
    final now = DateTime.now();
    final students = [
      _student(
        id: 'seed_s1',
        name: 'Arjun Mehta',
        dob: DateTime(2016, 5, 15),
        gender: 'male',
        school: 'Sunshine Primary',
        grade: 'Grade 3',
        status: 'applicationCreated',
        parentId: 'seed_parent_1',
        createdAt: now.subtract(const Duration(days: 6)),
        parentEmail: 'rajesh.mehta@example.com',
        parentPhone: '+91 98201 11001',
      ),
      _student(
        id: 'seed_s2',
        name: 'Priya Sharma',
        dob: DateTime(2018, 3, 22),
        gender: 'female',
        school: 'Moonbeam Kindergarten',
        grade: 'Grade 1',
        status: 'feePaid',
        parentId: 'seed_parent_2',
        createdAt: now.subtract(const Duration(days: 5)),
        paymentStatus: 'paid',
        parentEmail: 'deepa.sharma@example.com',
        parentPhone: '+91 99302 22002',
      ),
      _student(
        id: 'seed_s3',
        name: 'Rahul Nair',
        dob: DateTime(2014, 11, 8),
        gender: 'male',
        school: 'Green Valley School',
        grade: 'Grade 5',
        status: 'slotBooked',
        parentId: 'seed_parent_3',
        createdAt: now.subtract(const Duration(days: 4)),
        examSlotId: 'slot_seed_1',
        parentEmail: 'suresh.nair@example.com',
        parentPhone: '+91 97403 33003',
      ),
      _student(
        id: 'seed_s4',
        name: 'Sneha Patel',
        dob: DateTime(2017, 7, 30),
        gender: 'female',
        school: 'Bright Minds Academy',
        grade: 'Grade 2',
        status: 'examCompleted',
        parentId: 'seed_parent_4',
        createdAt: now.subtract(const Duration(days: 3)),
        examSlotId: 'slot_seed_1',
        examScore: 78,
        parentEmail: 'kavita.patel@example.com',
        parentPhone: '+91 96504 44004',
      ),
      _student(
        id: 'seed_s5',
        name: 'Aditya Kumar',
        dob: DateTime(2015, 9, 12),
        gender: 'male',
        school: 'Star Kids School',
        grade: 'Grade 4',
        status: 'admissionCompleted',
        parentId: 'seed_parent_5',
        createdAt: now.subtract(const Duration(days: 2)),
        examSlotId: 'slot_seed_2',
        examScore: 85,
        assignedCourse: 'Grade 4 — Science',
        parentEmail: 'vijay.kumar@example.com',
        parentPhone: '+91 95605 55005',
      ),
      _student(
        id: 'seed_s6',
        name: 'Ananya Krishnan',
        dob: DateTime(2013, 1, 25),
        gender: 'female',
        school: 'Heritage Public School',
        grade: 'Grade 6',
        status: 'feeSkipped',
        parentId: 'seed_parent_1',
        createdAt: now.subtract(const Duration(days: 1)),
        parentEmail: 'rajesh.mehta@example.com',
        parentPhone: '+91 98201 11001',
      ),
    ];

    for (final s in students) {
      final id = s['id'] as String;
      await _db.collection('students').doc(id).set({...s}..remove('id'));
    }
  }

  static Map<String, dynamic> _student({
    required String id,
    required String name,
    required DateTime dob,
    required String gender,
    required String school,
    required String grade,
    required String status,
    required String parentId,
    required DateTime createdAt,
    String? paymentStatus,
    String? examSlotId,
    int? examScore,
    String? assignedCourse,
    String? parentEmail,
    String? parentPhone,
  }) =>
      {
        'id': id,
        'name': name,
        'dateOfBirth': Timestamp.fromDate(dob),
        'gender': gender,
        'previousSchool': school,
        'applyingGrade': grade,
        'status': status,
        'parentId': parentId,
        'createdAt': Timestamp.fromDate(createdAt),
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (examSlotId != null) 'examSlotId': examSlotId,
        if (examScore != null) 'examScore': examScore,
        if (assignedCourse != null) 'assignedCourse': assignedCourse,
        if (parentEmail != null) 'parentEmail': parentEmail,
        if (parentPhone != null) 'parentPhone': parentPhone,
      };
}
