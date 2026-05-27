import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backend_auth_service.dart';
import '../domain/app_user.dart';
import '../../profile/data/profile_api_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
final otpSessionProvider = NotifierProvider<OtpSessionController, OtpSession>(
    OtpSessionController.new);

class OtpSession {
  const OtpSession({
    this.phone,
    this.isPending = false,
    this.isSending = false,
    this.canVerify = false,
    this.message,
  });

  final String? phone;
  final bool isPending;
  final bool isSending;
  final bool canVerify;
  final String? message;
}

class OtpSessionController extends Notifier<OtpSession> {
  @override
  OtpSession build() => const OtpSession();

  void start(String phone) {
    state = OtpSession(phone: phone, isPending: true, isSending: true);
  }

  void ready() {
    state = OtpSession(phone: state.phone, isPending: true, canVerify: true);
  }

  void failed(String message) {
    state = OtpSession(phone: state.phone, isPending: true, message: message);
  }

  void clear() {
    state = const OtpSession();
  }
}

class AuthController extends AsyncNotifier<AppUser?> {
  String? _verificationId;
  int? _resendToken;
  ConfirmationResult? _webConfirmationResult;
  PhoneAuthCredential? _autoRetrievedCredential;

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  @override
  Future<AppUser?> build() async {
    ref.listen<AsyncValue<AppUser?>>(
      _firebaseUserProvider,
      (_, next) {
        if (ref.read(otpSessionProvider).isPending &&
            next.valueOrNull == null) {
          return;
        }
        state = next;
      },
    );
    return _auth.currentUser?.toAppUser();
  }

  Future<void> requestOtp(String phone) async {
    state = const AsyncLoading();
    ref.read(otpSessionProvider.notifier).start(phone);
    _verificationId = null;
    _webConfirmationResult = null;
    _autoRetrievedCredential = null;

    if (_auth.currentUser != null) {
      await _auth.signOut();
    }

    if (kIsWeb) {
      try {
        await _applyDebugPhoneAuthSettings(phone);
        _webConfirmationResult = await _auth.signInWithPhoneNumber(phone);
        ref.read(otpSessionProvider.notifier).ready();
        state = const AsyncData(null);
        return;
      } on FirebaseAuthException catch (error, stackTrace) {
        ref
            .read(otpSessionProvider.notifier)
            .failed(_messageForFirebaseError(error));
        state = AsyncError(error, stackTrace);
        throw AuthException(_messageForFirebaseError(error), error);
      } catch (error, stackTrace) {
        ref
            .read(otpSessionProvider.notifier)
            .failed('Unable to send OTP. Please try again.');
        state = AsyncError(error, stackTrace);
        throw AuthException('Unable to send OTP. Please try again.', error);
      }
    }

    final completer = Completer<void>();
    final sendTimeout = Timer(const Duration(seconds: 18), () {
      if (state.isLoading) {
        ref.read(otpSessionProvider.notifier).failed(
              'OTP request did not complete. Check Firebase Phone Auth, SHA-1/SHA-256, and use a configured test number.',
            );
        state = const AsyncData(null);
      }
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await _applyDebugPhoneAuthSettings(phone);
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (credential) {
          sendTimeout.cancel();
          _autoRetrievedCredential = credential;
          ref.read(otpSessionProvider.notifier).ready();
          state = const AsyncData(null);
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (error) {
          sendTimeout.cancel();
          final message = _messageForFirebaseError(error);
          ref.read(otpSessionProvider.notifier).failed(message);
          state = AsyncError(error, StackTrace.current);
          if (!completer.isCompleted) {
            completer.completeError(AuthException(message, error));
          }
        },
        codeSent: (verificationId, resendToken) {
          sendTimeout.cancel();
          _verificationId = verificationId;
          _resendToken = resendToken;
          ref.read(otpSessionProvider.notifier).ready();
          state = const AsyncData(null);
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (error) {
      sendTimeout.cancel();
      final message = _messageForFirebaseError(error);
      ref.read(otpSessionProvider.notifier).failed(message);
      state = AsyncError(error, StackTrace.current);
      if (!completer.isCompleted) {
        completer.completeError(AuthException(message, error));
      }
    } catch (error) {
      sendTimeout.cancel();
      ref
          .read(otpSessionProvider.notifier)
          .failed('Unable to send OTP. Please try again.');
      state = AsyncError(error, StackTrace.current);
      if (!completer.isCompleted) {
        completer.completeError(
            AuthException('Unable to send OTP. Please try again.', error));
      }
    }

    return completer.future.timeout(
      const Duration(seconds: 18),
      onTimeout: () {
        ref.read(otpSessionProvider.notifier).failed(
              'OTP request did not complete. Check Firebase Phone Auth, SHA-1/SHA-256, and use a configured test number.',
            );
        state = const AsyncData(null);
      },
    );
  }

  Future<void> _applyDebugPhoneAuthSettings(String phone) {
    if (kReleaseMode) return Future<void>.value();
    const testPhone = String.fromEnvironment('FIREBASE_TEST_PHONE_NUMBER');
    const testSmsCode = String.fromEnvironment('FIREBASE_TEST_SMS_CODE');
    return _auth.setSettings(
      appVerificationDisabledForTesting: true,
      phoneNumber: testPhone.isEmpty ? null : testPhone,
      smsCode: testSmsCode.isEmpty ? null : testSmsCode,
    );
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    state = const AsyncLoading();
    try {
      if (kIsWeb) {
        final confirmation = _webConfirmationResult;
        if (confirmation == null) {
          throw FirebaseAuthException(
            code: 'missing-confirmation',
            message: 'Please request a fresh OTP.',
          );
        }
        await confirmation.confirm(otp);
      } else {
        final credential = _autoRetrievedCredential ??
            PhoneAuthProvider.credential(
              verificationId: _requireVerificationId(),
              smsCode: otp,
            );
        await _auth.signInWithCredential(credential);
      }

      final user = _auth.currentUser;
      final idToken = await user?.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw AuthException('Firebase did not return an ID token.');
      }
      await ref.read(backendAuthServiceProvider).verifyFirebaseToken(idToken);

      state = AsyncData(_auth.currentUser?.toAppUser());
      ref.read(otpSessionProvider.notifier).clear();
    } on FirebaseAuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      throw AuthException(_messageForFirebaseError(error), error);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      throw AuthException('Unable to verify OTP. Please try again.', error);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
    _webConfirmationResult = null;
    _autoRetrievedCredential = null;
    ref.read(otpSessionProvider.notifier).clear();
    state = const AsyncData(null);
  }

  Future<void> updateProfile({
    required String name,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('Please login before editing profile.');
    }
    state = const AsyncLoading();
    try {
      await ref
          .read(profileApiServiceProvider)
          .updateProfile(name: name, imageUrl: imageUrl);
      await user.updateDisplayName(name);
      if (imageUrl != null) await user.updatePhotoURL(imageUrl);
      await user.reload();
      state = AsyncData(_auth.currentUser?.toAppUser());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      throw AuthException('Unable to update profile. Please try again.', error);
    }
  }

  String _requireVerificationId() {
    final verificationId = _verificationId;
    if (verificationId == null) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'Please request a fresh OTP.',
      );
    }
    return verificationId;
  }
}

class AuthException implements Exception {
  AuthException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

String _messageForFirebaseError(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-phone-number' =>
      'Enter the phone number in international format, for example +919876543210.',
    'captcha-check-failed' =>
      'reCAPTCHA failed. Refresh the app and try again.',
    'web-context-cancelled' =>
      'reCAPTCHA was cancelled before OTP could be sent.',
    'web-context-already-presented' =>
      'A reCAPTCHA check is already open. Complete it or refresh the app.',
    'too-many-requests' =>
      'Too many OTP attempts. Wait a while or use a Firebase test phone number.',
    'quota-exceeded' => 'Firebase SMS quota is exhausted for this project.',
    'operation-not-allowed' =>
      'Phone sign-in is not enabled in Firebase Authentication.',
    'app-not-authorized' =>
      'This app is not authorized in Firebase. Check package name, SHA-1/SHA-256, and authorized domains.',
    'missing-client-identifier' =>
      'Firebase cannot verify this Android app. Add SHA-1 and SHA-256 fingerprints in Firebase Console.',
    'invalid-verification-code' =>
      'The OTP is incorrect. Please check the SMS and try again.',
    'session-expired' => 'The OTP expired. Please request a new code.',
    _ => error.message ?? 'Firebase login failed (${error.code}).',
  };
}

final _firebaseUserProvider = StreamProvider<AppUser?>((ref) {
  return ref
      .watch(firebaseAuthProvider)
      .authStateChanges()
      .map((user) => user?.toAppUser());
});

extension on User {
  AppUser toAppUser() {
    return AppUser(
      id: uid,
      phone: phoneNumber ?? '',
      name: displayName ?? 'NestBuddy Customer',
      email: email,
      imageUrl: photoURL,
    );
  }
}
