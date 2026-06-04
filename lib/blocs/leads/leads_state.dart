import 'package:equatable/equatable.dart';
import '../../models/lead.dart';

enum LeadsStatus { initial, loading, success, failure }

class LeadsState extends Equatable {
  final List<Lead> leads;
  final LeadsStatus status;
  final String? errorMessage;

  const LeadsState({
    this.leads = const [],
    this.status = LeadsStatus.initial,
    this.errorMessage,
  });

  LeadsState copyWith({
    List<Lead>? leads,
    LeadsStatus? status,
    String? errorMessage,
  }) {
    return LeadsState(
      leads: leads ?? this.leads,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [leads, status, errorMessage];

  Map<String, dynamic> toJson() {
    return {
      'leads': leads.map((l) => l.toJson()).toList(),
      'status': status.index,
    };
  }

  factory LeadsState.fromJson(Map<String, dynamic> json) {
    return LeadsState(
      leads: (json['leads'] as List<dynamic>?)
              ?.map((item) => Lead.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: LeadsStatus.values[json['status'] as int? ?? 0],
    );
  }
}
