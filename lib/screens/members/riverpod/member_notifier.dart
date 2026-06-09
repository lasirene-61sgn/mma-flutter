import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../service/api/api_client/api_client.dart';
import '../model/member_model.dart';

class MembersState {
  final bool isLoading;
  final List<Member> allMembers;
  final List<Member> membersList;
  final List<Member> filteredList; // Add this to hold the viewable list
  final String? error;

  const MembersState({
    this.isLoading = false,
    this.allMembers = const [],
    this.membersList = const [],
    this.filteredList = const [],
    this.error,
  });

  MembersState copyWith({
    bool? isLoading,
    List<Member>? allMembers,
    List<Member>? membersList,
    List<Member>? filteredList,
    String? error,
  }) {
    return MembersState(
      isLoading: isLoading ?? this.isLoading,
      allMembers: allMembers ?? this.allMembers,
      membersList: membersList ?? this.membersList,
      filteredList: filteredList ?? this.filteredList,
      error: error,
    );
  }
}

class MembersNotifier extends StateNotifier<MembersState> {
  MembersNotifier() : super(const MembersState());

  Future<void> loadMembers(String url) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient().get(
        endpoint: url
      );
      if (response["status"] == 1) {
        final dynamic rawData = response['data']?['data'];
        if (rawData is List) {
          final members = rawData.map((e) => Member.fromJson(e)).toList();
          state = state.copyWith(
              isLoading: false,
              allMembers: members,
              membersList: members,
              filteredList: members
          );
        }
      } else {
         state = state.copyWith(isLoading: false, error: response["message"]);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void filterByField(String fieldName, String value) {
    final results = state.allMembers.where((m) {
      switch (fieldName) {
        case 'Gotra': return m.gotra == value;
        case 'Area': return m.area == value;
        case 'Street/Road': return m.streetRoad == value;
        case 'Pincode': return m.pincode == value;
        default: return true;
      }
    }).toList();
    state = state.copyWith(membersList: results);
  }

  // Method to reset filter
  void resetFilter() {
    state = state.copyWith(filteredList: state.membersList);
  }
}

final membersNotifierProvider =
StateNotifierProvider<MembersNotifier, MembersState>(
      (ref) => MembersNotifier(),
);
