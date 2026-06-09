import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/service/api/api_client/api_client.dart';
import '../model/mmpct_model.dart';

class MmpctState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<MmpctMember> memberList;
  final List<MmpctCategory> categoryList;

  const MmpctState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.memberList = const [],
    this.categoryList = const [],
  });

  MmpctState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<MmpctMember>? memberList,
    List<MmpctCategory>? categoryList,
  }) {
    return MmpctState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      memberList: memberList ?? this.memberList,
      categoryList: categoryList ?? this.categoryList,
    );
  }
}

class MmpctNotifier extends Notifier<MmpctState> {
  @override
  MmpctState build() {
    return const MmpctState();
  }

  Future<void> loadMembers(String url) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: url);

      if (response["status"] == 1) {
        dynamic rawData = response['data'];

        if (rawData is Map && rawData['data'] is List) {
          rawData = rawData['data'];
          debugPrint("MMPCT MEMBER COUNT: $rawData");
        }

        if (rawData is List) {
          final members = rawData
              .map<MmpctMember>((e) => MmpctMember.fromJson(e as Map<String, dynamic>))
              .toList();

          debugPrint("MMPCT MEMBER COUNT: ${members.length} $members");

          state = state.copyWith(
            isLoading: false,
            memberList: members,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            memberList: [],
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Server returned error status',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load mmpct members: $e',
      );
    }
  }

  Future<void> loadCategory(String url) async {
    state = state.copyWith(isLoaded: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: url);
      debugPrint("MMPCT category COUNT: $response");
      if (response["status"] == 1) {
        final rawData = response['data']?['data'];

        if (rawData is List && rawData.isNotEmpty) {
          final categories =
          rawData.map((e) => MmpctCategory.fromJson(e as Map<String, dynamic>)).toList();

          debugPrint("MMPCT category COUNT: ${categories.length}");
          final allCategory = MmpctCategory(
            id: 0,
            categoryName: 'All',
          );

          state = state.copyWith(
            isLoaded: false,
            categoryList: [allCategory, ...categories],
          );
        } else {
          state = state.copyWith(isLoaded: false, categoryList: []);
        }
      } else {
        state = state.copyWith(
          isLoaded: false,
          error: 'Server returned error status',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoaded: false,
        error: 'Failed to load category: $e',
      );
    }
  }
}

final mmpctNotifierProvider = NotifierProvider<MmpctNotifier, MmpctState>(() {
  return MmpctNotifier();
});
