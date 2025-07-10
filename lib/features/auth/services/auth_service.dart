import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream để lắng nghe trạng thái đăng nhập (đăng nhập/đăng xuất)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Đăng nhập bằng Email & Mật khẩu
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Lỗi đăng nhập Email: ${e.message}');
      return null;
    }
  }

  // Đăng ký bằng Email, Mật khẩu và Tên hiển thị
  Future<User?> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      // 1. Tạo user bằng email và password trong Firebase Auth
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // 2. Cập nhật tên hiển thị cho user
        await user.updateProfile(displayName: displayName);
        await user.reload();

        // 3. Tạo một document mới trong collection 'users' với UID của user
        //    Đây là nơi lưu trữ các thông tin mở rộng như quyền hạn
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': Timestamp.now(),
          'subscriptionTier': null, // Quyền ban đầu là null, chờ xác thực
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Lỗi đăng ký Email: ${e.message}');
      return null;
    }
  }

  // Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // Người dùng đã hủy
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Nếu là lần đầu đăng nhập, tạo document trong Firestore
      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'createdAt': Timestamp.now(),
          'subscriptionTier': null,
        });
      }
      return user;
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return null;
    }
  }

  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(oAuthCredential);
      final User? user = userCredential.user;

      // Nếu là lần đầu đăng nhập, tạo document trong Firestore
      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim(),
          'createdAt': Timestamp.now(),
          'subscriptionTier': null,
        });
      }
      return user;
    } catch (e) {
      print('Lỗi đăng nhập Apple: $e');
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}