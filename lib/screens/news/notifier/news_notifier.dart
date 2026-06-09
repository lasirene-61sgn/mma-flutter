import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/service/api/api_client/api_client.dart';

import 'package:mmp_official/screens/news/model/news_model.dart';
import 'dart:io';

class NewsState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<News> newsList;
  final News? selectedNews;

  const NewsState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.newsList = const [],
    this.selectedNews,
  });

  NewsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<News>? newsList,
    News? selectedNews,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      newsList: newsList ?? this.newsList,
      selectedNews: selectedNews ?? this.selectedNews,
    );
  }
}

class NewsNotifier extends Notifier<NewsState> {
  @override
  NewsState build() {
    return const NewsState();
  }

  Future<void> loadNews() async {
    state = state.copyWith(
      isLoading: true,
      isLoaded: false,
      error: null,
    );

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/news');

      if (response["status"] == 1) {
        final dynamic rawData = response['data']?['data'];

        if (rawData != null && rawData is List) {
          final news = rawData
              .map((e) => News.fromJson(e as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            newsList: news,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isLoaded: true,
            newsList: const [],
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Server returned error status',
        );
      }
    } catch (e, s) {
      debugPrint("NEWS LOAD ERROR: $e");
      debugPrintStack(stackTrace: s);

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load news',
      );
    }
  }

  Future<void> submitNews(
    BuildContext context,
    Map<String, dynamic> payload, {
    String? newsId,
    File? profilePhoto,
    File? aadharPhoto,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final isCreate = newsId == null || newsId.isEmpty;

      final response = await ApiClient().requestWithFiles(
        endpoint: isCreate ? 'api/customer/news' : 'api/customer/news/$newsId',
        method: isCreate ? 'POST' : 'PUT',
        fields: payload,
        files: {
          if (profilePhoto != null) 'profilePhoto': profilePhoto,
          if (aadharPhoto != null) 'aadharPhoto': aadharPhoto,
        },
      );

      if (response['status'] == 1) {
        await loadNews();
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save news',
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> loadNewsDetails(String id) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/news/$id');
      final news = News.fromJson(response['data']?['data'] ?? response['data']);

      state = state.copyWith(
        isSaving: false,
        selectedNews: news,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to load news details',
      );
    }
  }
}

final newsNotifierProvider = NotifierProvider<NewsNotifier, NewsState>(() {
  return NewsNotifier();
});
