import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class LocalizationChanged extends LocalizationEvent {
  final Locale locale;

  const LocalizationChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

class LoadTranslations extends LocalizationEvent {}
