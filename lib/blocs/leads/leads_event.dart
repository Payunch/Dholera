import 'package:equatable/equatable.dart';
import '../../models/lead.dart';

abstract class LeadsEvent extends Equatable {
  const LeadsEvent();
  @override
  List<Object?> get props => [];
}

class FetchLeadsRequested extends LeadsEvent {
  final bool refresh;
  const FetchLeadsRequested({this.refresh = false});
  @override
  List<Object?> get props => [refresh];
}

class LeadAddedManually extends LeadsEvent {
  final Lead lead;
  const LeadAddedManually(this.lead);
  @override
  List<Object?> get props => [lead];
}
