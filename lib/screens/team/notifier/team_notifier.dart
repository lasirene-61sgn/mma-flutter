import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/service/api/api_client/api_client.dart';
import '../model/team_model.dart';

class TeamState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<TeamMember> teamList;
  final TeamMember? selectedTeam;

  const TeamState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.teamList = const [],
    this.selectedTeam,
  });

  TeamState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<TeamMember>? teamList,
    TeamMember? selectedTeam,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      teamList: teamList ?? this.teamList,
      selectedTeam: selectedTeam ?? this.selectedTeam,
    );
  }
}

class TeamNotifier extends Notifier<TeamState> {
  @override
  TeamState build() {
    return const TeamState();
  }

  Future<void> loadTeam() async {
    state = state.copyWith(isLoading: true, isLoaded: false, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/committee');

      if (response['status'] == 1) {
        final List rawList = response['data']?['data'] ?? [];

        final teams = rawList
            .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          teamList: teams,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Server error',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load team',
      );
    }
  }

  Future<void> loadTeamDetails(String id) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/committee/$id');
      final team = TeamMember.fromJson(response['data']?['data'] ?? response['data']);

      state = state.copyWith(
        isSaving: false,
        selectedTeam: team,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to load team details',
      );
    }
  }
}

final teamNotifierProvider = NotifierProvider<TeamNotifier, TeamState>(() {
  return TeamNotifier();
});
