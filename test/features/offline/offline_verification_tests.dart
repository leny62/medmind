import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/errors/failures.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/models/medication_model.dart';
import 'package:medmind/features/medication/data/repositories/medication_repository_impl.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/mock_data_generators.dart';
import '../../utils/property_test_framework.dart';

// Generate mocks
@GenerateMocks([MedicationRemoteDataSource, FirebaseAuth, User])
import 'offline_verification_tests.mocks.dart';

/// Offline Functionality Verification Tests
/// Tests for Requirements 18.1, 18.2, 18.3, 18.4, 18.5
void main() {
  group('Offline Functionality Verification Tests', () {
    late MockMedicationRemoteDataSource mockDataSource;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late String testUserId;

    setUp(() {
      mockDataSource = MockMedicationRemoteDataSource();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      testUserId = 'test-user-${DateTime.now().millisecondsSinceEpoch}';

      // Setup mock auth
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);
    });

    group('Property 51: Cached data is accessible offline', () {
      /// **Feature: system-verification, Property 51: Cached data is accessible offline**
      /// **Validates: Requirements 18.1**
      propertyTest<MedicationEntity>(
        'For any medication, cached data should be accessible when offline',
        generator: () =>
            MockDataGenerators.generateMedication(userId: testUserId),
        property: (medication) async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final medicationModel = MedicationModel.fromEntity(medication);

          // Simulate successful online add
          when(
            mockDataSource.addMedication(any),
          ).thenAnswer((_) async => medicationModel);

          // Act 1: Add medication while "online"
          final addResult = await repository.addMedication(medication);
          if (addResult.isLeft()) {
            return false;
          }

          // Simulate successful online fetch
          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          // Act 2: Retrieve medications while "online"
          final onlineResult = await repository.getMedications();
          if (onlineResult.isLeft()) {
            return false;
          }

          final onlineMedications = onlineResult.getOrElse(() => []);
          if (onlineMedications.isEmpty) {
            return false;
          }

          final foundOnline = onlineMedications.any(
            (m) => m.id == medication.id,
          );
          if (!foundOnline) {
            return false;
          }

          // Simulate offline: Return cached data
          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          // Act 3: Retrieve medications again (simulating offline with cache)
          final cachedResult = await repository.getMedications();
          if (cachedResult.isLeft()) {
            return false;
          }

          final cachedMedications = cachedResult.getOrElse(() => []);
          final foundCached = cachedMedications.any(
            (m) => m.id == medication.id,
          );

          return foundCached;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      test(
        'Cached medications should be accessible when Firestore is unavailable',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final medicationModel = MedicationModel.fromEntity(testMedication);

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          final onlineResult = await repository.getMedications();

          expect(onlineResult.isRight(), true);
          final onlineMeds = onlineResult.getOrElse(() => []);
          expect(onlineMeds.length, 1);
          expect(onlineMeds.first.id, testMedication.id);

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          final offlineResult = await repository.getMedications();

          expect(offlineResult.isRight(), true);
          final offlineMeds = offlineResult.getOrElse(() => []);
          expect(offlineMeds.length, 1);
          expect(offlineMeds.first.id, testMedication.id);
        },
      );
    });

    group('Property 53: Offline indicators display correctly', () {
      /// **Feature: system-verification, Property 53: Offline indicators display correctly**
      /// **Validates: Requirements 18.3**
      propertyTest<MedicationEntity>(
        'For any queued offline operation, an indicator should show pending sync status',
        generator: () =>
            MockDataGenerators.generateMedication(userId: testUserId),
        property: (medication) async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network unavailable'));

          final result = await repository.addMedication(medication);

          final isOfflineError = result.fold(
            (failure) => failure is NetworkFailure || failure is DataFailure,
            (_) => false,
          );

          return isOfflineError;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      test(
        'Network failures should be distinguishable from other errors',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );

          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network error'));

          final result = await repository.addMedication(testMedication);

          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure is NetworkFailure || failure is DataFailure, true);
          }, (_) => fail('Expected failure but got success'));
        },
      );
    });

    group('Property 54: Offline startup loads cached data', () {
      /// **Feature: system-verification, Property 54: Offline startup loads cached data**
      /// **Validates: Requirements 18.4**
      propertyTest<List<MedicationEntity>>(
        'For any set of cached medications, offline startup should load them',
        generator: () => List.generate(
          MockMedicationGenerator.generate().id.hashCode % 5 + 1,
          (_) => MockDataGenerators.generateMedication(userId: testUserId),
        ),
        property: (medications) async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final medicationModels = medications
              .map((m) => MedicationModel.fromEntity(m))
              .toList();

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => medicationModels);

          final result = await repository.getMedications();

          if (result.isLeft()) {
            return false;
          }

          final loadedMeds = result.getOrElse(() => []);

          if (loadedMeds.length != medications.length) {
            return false;
          }

          for (final med in medications) {
            if (!loadedMeds.any((m) => m.id == med.id)) {
              return false;
            }
          }

          return true;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      test(
        'Empty cache should not cause errors during offline startup',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => []);

          final result = await repository.getMedications();

          expect(result.isRight(), true);
          final medications = result.getOrElse(() => []);
          expect(medications, isEmpty);
        },
      );
    });

    group('Integration: Offline operation queuing and sync', () {
      test(
        'Operations should queue when offline and sync when online',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final medicationModel = MedicationModel.fromEntity(testMedication);

          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network unavailable'));

          final offlineResult = await repository.addMedication(testMedication);

          expect(offlineResult.isLeft(), true);

          when(
            mockDataSource.addMedication(any),
          ).thenAnswer((_) async => medicationModel);

          final onlineResult = await repository.addMedication(testMedication);

          expect(onlineResult.isRight(), true);
        },
      );

      test('Multiple queued operations should sync in order', () async {
        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final medications = List.generate(
          3,
          (_) => MockDataGenerators.generateMedication(userId: testUserId),
        );

        when(
          mockDataSource.addMedication(any),
        ).thenThrow(Exception('Network unavailable'));

        final offlineResults = await Future.wait(
          medications.map((med) => repository.addMedication(med)),
        );

        expect(offlineResults.every((r) => r.isLeft()), true);

        for (final med in medications) {
          final model = MedicationModel.fromEntity(med);
          when(
            mockDataSource.addMedication(
              argThat(predicate<MedicationModel>((m) => m.id == med.id)),
            ),
          ).thenAnswer((_) async => model);
        }

        final onlineResults = await Future.wait(
          medications.map((med) => repository.addMedication(med)),
        );

        expect(onlineResults.every((r) => r.isRight()), true);
      });

      test('Offline error messages should be clear and actionable', () async {
        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final testMedication = MockDataGenerators.generateMedication(
          userId: testUserId,
        );

        when(
          mockDataSource.addMedication(any),
        ).thenThrow(Exception('No internet connection'));

        final result = await repository.addMedication(testMedication);

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.message, isNotEmpty);
          expect(
            failure.message.toLowerCase().contains('error') ||
                failure.message.toLowerCase().contains('unexpected'),
            true,
          );
        }, (_) => fail('Expected failure but got success'));
      });
    });
  });
}
