import 'package:admitly/core/errors/exceptions.dart';
import 'package:admitly/core/utils/app_logger.dart';
import 'package:admitly/features/auth/data/models/user_model.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth, this._firestore, this._googleSignIn);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _fetchUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      appLogger.e('Login failed', error: e);
      throw AuthException(_authErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final model = UserModel(
        uid: user.uid,
        email: email.trim(),
        name: name.trim(),
        role: UserRole.parent,
      );
      await _firestore.collection('users').doc(user.uid).set(model.toMap());
      appLogger.i('User registered: ${user.uid}');
      return model;
    } on FirebaseAuthException catch (e) {
      appLogger.e('Register failed', error: e);
      throw AuthException(_authErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Google sign-in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final model = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          role: UserRole.parent,
        );
        await _firestore.collection('users').doc(user.uid).set(model.toMap());
        return model;
      }
      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      appLogger.e('Google sign-in failed', error: e);
      throw AuthException(_authErrorMessage(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      appLogger.e('Google sign-in error', error: e);
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    appLogger.i('User logged out');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _fetchUserFromFirestore(user.uid);
  }

  Future<UserModel> _fetchUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw const AuthException('User profile not found');
    return UserModel.fromMap(doc.data()!);
  }

  String _authErrorMessage(String code) => switch (code) {
        'user-not-found' => 'No account found with this email',
        'wrong-password' => 'Incorrect password',
        'email-already-in-use' => 'Email is already registered',
        'invalid-email' => 'Invalid email address',
        'weak-password' => 'Password is too weak',
        'network-request-failed' => 'No internet connection',
        'too-many-requests' => 'Too many attempts. Try again later',
        _ => 'Authentication failed. Please try again',
      };
}
