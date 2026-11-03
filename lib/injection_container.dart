import 'package:admitly/core/services/biometric_service.dart';
import 'package:admitly/core/services/secure_storage_service.dart';
import 'package:admitly/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:admitly/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:admitly/features/auth/domain/repositories/auth_repository.dart';
import 'package:admitly/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/login_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:admitly/features/auth/domain/usecases/register_usecase.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/exam_slot/data/datasources/exam_slot_remote_datasource.dart';
import 'package:admitly/features/exam_slot/data/repositories/exam_slot_repository_impl.dart';
import 'package:admitly/features/exam_slot/domain/repositories/exam_slot_repository.dart';
import 'package:admitly/features/exam_slot/domain/usecases/book_exam_slot_usecase.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_exam_slots_usecase.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/student/data/datasources/student_remote_datasource.dart';
import 'package:admitly/features/student/data/repositories/student_repository_impl.dart';
import 'package:admitly/features/student/domain/repositories/student_repository.dart';
import 'package:admitly/features/student/domain/usecases/create_student_usecase.dart';
import 'package:admitly/features/student/domain/usecases/get_students_usecase.dart';
import 'package:admitly/features/student/domain/usecases/update_student_usecase.dart';
// ignore: depend_on_referenced_packages
import 'package:admitly/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Core services
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => BiometricService());

  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Exam Slot
  sl.registerLazySingleton<ExamSlotRemoteDataSource>(
    () => ExamSlotRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExamSlotRepository>(
    () => ExamSlotRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetExamSlotsUseCase(sl()));
  sl.registerLazySingleton(() => BookExamSlotUseCase(sl()));
  sl.registerFactory(() => ExamSlotBloc(
        getExamSlotsUseCase: sl(),
        bookExamSlotUseCase: sl(),
      ));

  // Student
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => CreateStudentUseCase(sl()));
  sl.registerLazySingleton(() => GetStudentsByParentUseCase(sl()));
  sl.registerLazySingleton(() => GetAllStudentsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStudentUseCase(sl()));

  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        googleSignInUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        biometricService: sl(),
        secureStorageService: sl(),
        authRepository: sl(),
      ));
}
