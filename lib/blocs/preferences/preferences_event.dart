import 'package:equatable/equatable.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();
  @override
  List<Object?> get props => [];
}

class LanguageSelected extends PreferencesEvent {}
class OnboardingCompleted extends PreferencesEvent {}
