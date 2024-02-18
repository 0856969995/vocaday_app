import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/typedef/typedefs.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;

  UserRepositoryImpl(this.userRemoteDataSource);

  @override
  FutureEither<void> addUserProfile(UserEntity userEntity) async {
    try {
      final userModel = UserModel.fromEntity(userEntity);
      return Right(
        await userRemoteDataSource.addUserProfile(
          uid: userModel.uid,
          map: userModel.toMap(),
        ),
      );
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(e.message ?? 'FirebaseFailure: addUserProfile'),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> getUserData(String uid) async* {
    yield* userRemoteDataSource.getUserData(uid).map((data) {
      if (data != null) {
        return UserModel.fromMap(data).toEntity();
      } else {
        return null;
      }
    });
  }

  @override
  FutureEither<void> updateUserProfile(UserEntity userEntity) async {
    try {
      final userModel = UserModel.fromEntity(userEntity);
      return Right(
        await userRemoteDataSource.updateUserProfile(
          uid: userModel.uid,
          map: userModel.toMapUpdate(),
        ),
      );
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(e.message ?? 'FirebaseFailure: updateUserProfile'),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  FutureEither<bool> addAttendanceDate({
    required String uid,
    required List<DateTime> attendance,
  }) async {
    try {
      return Right(
        await userRemoteDataSource.addAttendanceDate(
          uid: uid,
          map: {
            'attendance':
                attendance.map((x) => x.millisecondsSinceEpoch).toList(),
          },
        ),
      );
    } on FirebaseException catch (e) {
      return Left(
        FirebaseFailure(e.message ?? 'FirebaseFailure: addAttendanceDate'),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
