import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/gallery_model.dart';
import '../../../service/api/api_client/api_client.dart';

/// ======================
/// STATE
/// ======================
class GalleryState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<GalleryModel> galleryList;
  final GalleryModel? selectedGallery;

  const GalleryState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.galleryList = const [],
    this.selectedGallery,
  });

  GalleryState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<GalleryModel>? galleryList,
    GalleryModel? selectedGallery,
  }) {
    return GalleryState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      galleryList: galleryList ?? this.galleryList,
      selectedGallery: selectedGallery ?? this.selectedGallery,
    );
  }
}

/// ======================
/// NOTIFIER
/// ======================
class GalleryNotifier extends Notifier<GalleryState> {
  @override
  GalleryState build() {
    return const GalleryState();
  }

  /// ======================
  /// LOAD GALLERY LIST
  /// ======================
  Future<void> loadGallery() async {
    state = state.copyWith(
      isLoading: true,
      isLoaded: false,
      error: null,
    );

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/gallery');
      if (response['status'] == 1) {
        final dynamic rawData = response['data']?['data'];

        if (rawData is List) {
          final galleries = rawData
              .map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            galleryList: galleries,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            galleryList: const [],
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
        error: 'Failed to load gallery: $e',
      );
    }
  }

  /// ======================
  /// CREATE / UPDATE GALLERY
  /// ======================
  Future<void> submitGallery(
      BuildContext context,
      Map<String, dynamic> payload, {
        String? galleryId,
        PlatformFile? profilePhoto,
        PlatformFile? aadharPhoto,
      }) async {
    // Ignored as per user instructions
  }

  /// ======================
  /// LOAD SINGLE GALLERY
  /// ======================
  Future<void> loadGalleryDetails(String id) async {
    // Ignored as per user instructions
  }
}

/// ======================
/// PROVIDER
/// ======================
final galleryNotifierProvider = NotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);
