import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:admitly/features/student/presentation/views/student_detail_screen.dart';
import 'package:admitly/features/student/presentation/widgets/create_student_sheet.dart';
import 'package:admitly/features/student/presentation/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key, required this.user});
  final UserEntity user;

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid));
  }

  Future<void> _openCreateSheet() async {
    await showCreateStudentSheet(context, parentId: widget.user.uid);
    if (!mounted) return;
    context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid));
  }

  Future<void> _openDetail(StudentEntity student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<StudentBloc>(),
          child: StudentDetailScreen(student: student, viewer: widget.user),
        ),
      ),
    );
    if (!mounted) return;
    context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'My Students',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        backgroundColor: colors.primary,
        label: Text(
          'Add Student',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 14, color: colors.error)),
            );
          }
          if (state is StudentLoaded) {
            if (state.students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined, size: 56.w, color: colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      'No students yet',
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.text),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Tap + to add your first student',
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 13, color: colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.students.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) => StudentCard(
                student: state.students[i],
                onTap: () => _openDetail(state.students[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
