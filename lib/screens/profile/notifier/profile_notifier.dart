import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/service/api/api_client/api_client.dart';
import 'package:mmp_official/screens/profile/model/profile_model.dart';
import 'package:mmp_official/service/toaster.dart';
import 'package:mmp_official/service/api/local_storage/shared_preference.dart';
import 'package:mmp_official/service/route/route_name.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:mmp_official/screens/profile/model/family_member_model.dart';

// Dummy classes for the ones missing from the user snippet
class AboutUsModel {
  AboutUsModel();
  factory AboutUsModel.fromJson(Map<String, dynamic> json) => AboutUsModel();
}

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final bool isLoaded;
  final String? error;
  final AboutUsModel? aboutUs;
  final Profile? profile;
  final List<FamilyMember>? familyMember;
  final Profile? selectedProfile;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.isLoaded = false,
    this.error,
    this.profile,
    this.selectedProfile,
    this.familyMember,
    this.aboutUs,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    bool? isLoaded,
    String? error,
    Profile? profile,
    List<FamilyMember>? familyMember,
    Profile? selectedProfile,
    AboutUsModel? aboutUs,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      profile: profile ?? this.profile,
      familyMember: familyMember ?? this.familyMember,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      aboutUs: aboutUs ?? this.aboutUs,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/profile');

      if (response['status'] == 1 && response['data']?['data'] != null) {
        final profile = Profile.fromJson(response['data']?['data']);

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          profile: profile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid profile response',
        );
      }
    } catch (e, s) {
      debugPrint("PROFILE LOAD ERROR: $e");
      debugPrintStack(stackTrace: s);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile',
      );
    }
  }

  Future<void> loadAboutUS() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/about-us');

      if (response != null &&
          response['data'] != null &&
          response['data']['status'] == "success" &&
          response['data']['data'] != null) {
        final about = AboutUsModel.fromJson(response['data']['data']);
        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          aboutUs: about,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid About Us response',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load About Us',
      );
    }
  }

  Future<void> loadMember() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/family-members/');

      if (response['status'] == 1 && response['data']?['data'] != null) {
        final List<dynamic> dataList = response['data']['data'];
        final members = dataList.map((item) => FamilyMember.fromJson(item)).toList();

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          familyMember: members,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'No family data found');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load family');
    }
  }

  Future<void> submitProfile(
    BuildContext context,
    Map<String, dynamic> payload,
    File? profileImage,
    [File? backgroundImage]
  ) async {
    state = state.copyWith(isSaving: true, error: null);
print("Image:$profileImage");
    try {
      final response = await ApiClient().requestWithFiles(
        endpoint: 'api/customer/profile',
        method: 'Post',
        fields: payload,
        files: {
          if (profileImage != null) 'image': profileImage,
          if (backgroundImage != null) 'background_image': backgroundImage,
        },
      );

      if (response['status'] == "success" || response['status'] == 1) {
        await loadProfile();
        state = state.copyWith(isSaving: false, error: null);
        Toaster.showSuccess(response['message']?.toString() ?? "Profile updated successfully");
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        state = state.copyWith(isSaving: false);
        Toaster.showError(response['message']?.toString() ?? "Failed to update profile");
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      Toaster.showError("Error: ${e.toString()}");
    }
  }
  Future<void> addFamily(
    BuildContext context,
    File? profileImage,
    Map<String, dynamic> payload,
  ) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().requestWithFiles(
        endpoint: 'api/customer/family-members',
        method: 'POST',
        fields: payload,
        files: {
          if (profileImage != null) 'image': profileImage,
        },
      );

      if (response['status'] == 1 || response['status'] == 'success') {
        await loadMember();
        state = state.copyWith(isSaving: false, error: null);
        Toaster.showSuccess(response['message']?.toString() ?? "Family member added successfully");
      } else {
        state = state.copyWith(isSaving: false);
        Toaster.showError(response['message']?.toString() ?? "Failed to add family member");
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save family member',
      );
      Toaster.showError("Error: ${e.toString()}");
    }
  }

  Future<void> updateFamily(
    BuildContext context,
    String memberId,
    File? profileImage,
    Map<String, dynamic> payload,
  ) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().requestWithFiles(
        endpoint: 'api/customer/family-members/$memberId',
        method: 'PUT',
        fields: payload,
        files: {
          if (profileImage != null) 'image': profileImage,
        },
      );

      if (response['status'] == 1 || response['status'] == 'success') {
        await loadMember();
        state = state.copyWith(isSaving: false, error: null);
        Toaster.showSuccess(response['message']?.toString() ?? "Family member updated successfully");
      } else {
        state = state.copyWith(isSaving: false);
        Toaster.showError(response['message']?.toString() ?? "Failed to update family member");
      }
    } catch (e) {
      debugPrint("UPDATE FAMILY ERROR: $e");
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update family member',
      );
      Toaster.showError("Error: ${e.toString()}");
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isDeleting: true);
    try {
      final response = await ApiClient().post(
        endpoint: 'api/customer/delete-account',
        body: {},
      );
      if (response['status'] == 1) {
        await SharedPreferencesHelper().init();
        await SharedPreferencesHelper().clear();

        Get.offAllNamed(RouteName.login);

        Toaster.showSuccess(response['data']?["message"] ?? "Account Deleted Successfully");
        state = state.copyWith(isDeleting: false, error: null);
      } else {
        Toaster.showError(response['message'] ?? response['message']?["message"] ?? "Account Delete failed");
        state = state.copyWith(isDeleting: false, error: "Account Delete failed");
      }
    } catch (e, stackTrace) {
      debugPrint("Delete account error: $e\n$stackTrace");
      state = state.copyWith(isDeleting: false, error: "Account Delete failed");
      Toaster.showError("Account Delete failed");
    }
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
