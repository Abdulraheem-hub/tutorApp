/// @context7:feature:dependency_injection
/// @context7:dependencies:get_it,firebase_services,repositories
/// @context7:pattern:service_locator
///
/// Dependency injection setup for the TutorPay application
library;

import 'package:get_it/get_it.dart';
import '../services/firebase_service.dart';
import '../../features/authentication/domain/repositories/authentication_repository.dart';
import '../../features/authentication/data/repositories/firebase_authentication_repository.dart';
import '../../features/students/domain/repositories/students_repository.dart';
import '../../features/students/data/repositories/firestore_students_repository.dart';
import '../../features/students/presentation/bloc/students_bloc.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core Services
  serviceLocator.registerLazySingleton<FirebaseService>(
    () => FirebaseService.instance,
  );

  // Repositories
  serviceLocator.registerLazySingleton<AuthenticationRepository>(
    () => FirebaseAuthenticationRepository(),
  );

  serviceLocator.registerLazySingleton<StudentsRepository>(
    () => FirestoreStudentsRepository(),
  );

  // BLoCs
  serviceLocator.registerFactory<StudentsBloc>(
    () => StudentsBloc(studentsRepository: serviceLocator()),
  );

  // Add more repositories and blocs as needed...
}

/// Clear all dependencies (useful for testing)
Future<void> clearDependencies() async {
  await serviceLocator.reset();
}
