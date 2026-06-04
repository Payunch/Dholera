import 'package:equatable/equatable.dart';

class PreferencesState extends Equatable {
  final bool isLanguageSelected;
  final bool isOnboardingDone;

  const PreferencesState({
    this.isLanguageSelected = false,
    this.isOnboardingDone = false,
  });

  PreferencesState copyWith({
    bool? isLanguageSelected,
    bool? isOnboardingDone,
  }) {
    return PreferencesState(
      isLanguageSelected: isLanguageSelected ?? this.isLanguageSelected,
      isOnboardingDone: isOnboardingDone ?? this.isOnboardingDone,
    );
  }

  @override
  List<Object?> get props => [isLanguageSelected, isOnboardingDone];

  Map<String, dynamic> toJson() => {
        'isLanguageSelected': isLanguageSelected,
        'isOnboardingDone': isOnboardingDone,
      };

  factory PreferencesState.fromJson(Map<String, dynamic> json) => PreferencesState(
        isLanguageSelected: json['isLanguageSelected'] as bool? ?? false,
        isOnboardingDone: json['isOnboardingDone'] as bool? ?? false,
      );
}
