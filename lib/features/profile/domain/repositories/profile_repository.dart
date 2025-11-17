import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserPreferencesEntity>> getPreferences();
  Future<Either<Failure, void>> savePreferences(UserPreferencesEntity preferences);
  Future<Either<Failure, UserPreferencesEntity>> updateThemeMode(ThemeMode themeMode);
  Future<Either<Failure, UserPreferencesEntity>> updateNotifications(bool enabled);
  Future<Either<Failure, void>> clearAllData();
}
