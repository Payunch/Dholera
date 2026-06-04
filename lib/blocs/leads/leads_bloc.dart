import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../services/api_service.dart';
import '../../models/lead.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadsBloc extends HydratedBloc<LeadsEvent, LeadsState> {
  final ApiService _apiService = ApiService();

  LeadsBloc() : super(const LeadsState()) {
    on<FetchLeadsRequested>((event, emit) async {
      if (event.refresh) {
        emit(state.copyWith(status: LeadsStatus.loading));
      }

      try {
        final response = await _apiService.getLeads();
        if (response['success'] == true || response['leads'] != null) {
          final List<dynamic> leadsData = response['leads'] ?? [];
          final List<Lead> fetchedLeads = Lead.fromList(leadsData);
          
          emit(state.copyWith(
            status: LeadsStatus.success,
            leads: fetchedLeads,
          ));
        } else {
          emit(state.copyWith(
            status: LeadsStatus.failure,
            errorMessage: response['error'] ?? 'Failed to fetch leads',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: LeadsStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    });

    on<LeadAddedManually>((event, emit) {
      final updatedLeads = List<Lead>.from(state.leads);
      final index = updatedLeads.indexWhere((l) => l.phone == event.lead.phone);
      if (index != -1) {
        updatedLeads[index] = event.lead;
      } else {
        updatedLeads.insert(0, event.lead);
      }
      emit(state.copyWith(leads: updatedLeads));
    });
  }

  @override
  LeadsState? fromJson(Map<String, dynamic> json) => LeadsState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(LeadsState state) => state.toJson();
}
