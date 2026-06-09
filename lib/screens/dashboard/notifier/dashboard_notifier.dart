import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mmp_official/screens/dashboard/model/banner_model.dart';
import 'package:mmp_official/screens/dashboard/model/dashboard_model.dart';
import 'package:mmp_official/screens/dashboard/model/dashboard_counters_model.dart';
import 'package:mmp_official/screens/dashboard/model/notifiction_model.dart';
import 'package:mmp_official/service/api/api_client/api_client.dart';

class DashboardState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final bool isDonate;
  final String? error;

  final int todayBirthdayCount;
  final Map<String, Map<String, List<BirthdayModel>>> birthdayData;
  final int todayAnniversaryCount;
  final Map<String, Map<String, List<BirthdayModel>>> anniversaryData;
  final List<AppNotification> notification;
  final List<BannerModel> banners;
  final DonateModel? donate;
  final SocialLinksModel? socialLinks;
  final DashboardCountersModel? dashboardCounters;

  const DashboardState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.isDonate = false,
    this.error,
    this.todayBirthdayCount = 0,
    this.birthdayData = const {},
    this.todayAnniversaryCount = 0,
    this.anniversaryData = const {},
    this.notification = const [],
    this.banners = const [],
    this.donate,
    this.socialLinks,
    this.dashboardCounters,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    bool? isDonate,
    String? error,
    int? todayBirthdayCount,
    Map<String, Map<String, List<BirthdayModel>>>? birthdayData,
    int? todayAnniversaryCount,
    Map<String, Map<String, List<BirthdayModel>>>? anniversaryData,
    List<AppNotification>? notification,
    List<BannerModel>? banners,
    DonateModel? donate,
    SocialLinksModel? socialLinks,
    DashboardCountersModel? dashboardCounters,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      isDonate: isDonate ?? this.isDonate,
      donate: donate ?? this.donate,
      error: error,
      todayBirthdayCount: todayBirthdayCount ?? this.todayBirthdayCount,
      birthdayData: birthdayData ?? this.birthdayData,
      todayAnniversaryCount: todayAnniversaryCount ?? this.todayAnniversaryCount,
      anniversaryData: anniversaryData ?? this.anniversaryData,
      notification: notification ?? this.notification,
      banners: banners ?? this.banners,
      socialLinks: socialLinks ?? this.socialLinks,
      dashboardCounters: dashboardCounters ?? this.dashboardCounters,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardState();
  }

  Future<void> loadDonate() async {
    state = state.copyWith(isDonate: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/qr-code');

      if (response['status'] == 1) {
        final Map<String, dynamic>? responseData = response['data'] as Map<String, dynamic>?;
        final rawData = responseData?['data'] as Map<String, dynamic>?;

        final donateModel = rawData != null ? DonateModel.fromJson(rawData) : null;

        state = state.copyWith(
          isDonate: false,
          donate: donateModel,
        );
      } else {
        state = state.copyWith(
          isDonate: false,
          error: 'Server returned error status for donate',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isDonate: false,
        error: 'Failed to load donate data',
      );
    }
  }
  /// ======================
  /// LOAD BIRTHDAY LIST
  /// ======================
  Future<void> loadBirthdays() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/today-birthdays');

      if (response['status'] == 1) {
        final decoded = response['data'] is Map ? response['data'] : {};
        final int count = decoded['today_count'] ?? 0;
        final rawData = decoded['data'];

        final Map<String, Map<String, List<BirthdayModel>>> map = {};
        if (rawData is Map) {
          rawData.forEach((monthKey, monthData) {
            if (monthData is Map) {
              final Map<String, List<BirthdayModel>> dateMap = {};
              monthData.forEach((dateKey, dateList) {
                if (dateList is List) {
                  final List<BirthdayModel> list = [];
                  for (var item in dateList) {
                    if (item is Map<String, dynamic>) {
                      try {
                        list.add(BirthdayModel.fromJson(item));
                      } catch(e) {
                        debugPrint("Error parsing birthday member in $dateKey: $e");
                      }
                    }
                  }
                  if (list.isNotEmpty) {
                    dateMap[dateKey.toString()] = list;
                  }
                }
              });
              map[monthKey.toString()] = dateMap;
            }
          });
        }

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          todayBirthdayCount: count,
          birthdayData: map,
        );
      } else {
         state = state.copyWith(
          isLoading: false,
          error: 'Failed to load birthdays',
        );
      }
    } catch (e, stacktrace) {
      debugPrint("Error loading birthdays: $e\n$stacktrace");
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load birthdays: $e',
      );
    }
  }

  Future<void> loadBanner() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/banner');

      if (response['status'] == 1) {
        final rawData = response['data']?['data'] as List? ?? [];

        final list = rawData.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
        print("this is a banner : $list");

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          banners: list,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load banner',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load banner',
      );
    }
  }

  Future<void> loadNotification() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/all-notifications');

      if (response['status'] == 1) {
        final rawData = response['data']?['data'] as List? ?? [];

        final list = rawData.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
        print(list);
        state = state.copyWith(
          isSaving: false,
          notification: list,
        );
      }
    } catch (e) {
      print(" error  ${e.toString()}");
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to load notifications',
      );
    }
  }

  Future<void> loadNotificationPost() async {
    try {
      final response = await ApiClient().post(endpoint: 'api/customer/notifications/mark-all-read');

      if (response['status'] == 1) {
        await loadNotification();
      }
    } catch (e) {
      debugPrint("Error marking notifications as read: ${e.toString()}");
    }
  }

  Future<void> loadSingleNotificationPost(String id) async {
    try {
      final response = await ApiClient().post(endpoint: 'api/customer/notifications/$id/read');
      print("marking Single notifications as read: $response");
      if (response['status'] == 1) {
        await loadNotification();
      }
    } catch (e) {
      debugPrint("Error marking notifications as read: ${e.toString()}");
    }
  }

  Future<void> loadAnniversaries() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/today-anniversaries');

      if (response['status'] == 1) {
        final decoded = response['data'] is Map ? response['data'] : {};
        final int count = decoded['today_count'] ?? 0;
        final rawData = decoded['data'];

        final Map<String, Map<String, List<BirthdayModel>>> map = {};
        if (rawData is Map) {
          rawData.forEach((monthKey, monthData) {
            if (monthData is Map) {
              final Map<String, List<BirthdayModel>> dateMap = {};
              monthData.forEach((dateKey, dateList) {
                if (dateList is List) {
                  final List<BirthdayModel> list = [];
                  for (var item in dateList) {
                    if (item is Map<String, dynamic>) {
                      try {
                        list.add(BirthdayModel.fromJson(item));
                      } catch(e) {
                        debugPrint("Error parsing anniversary member in $dateKey: $e");
                      }
                    }
                  }
                  if (list.isNotEmpty) {
                    dateMap[dateKey.toString()] = list;
                  }
                }
              });
              map[monthKey.toString()] = dateMap;
            }
          });
        }

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          todayAnniversaryCount: count,
          anniversaryData: map,
        );
      } else {
         state = state.copyWith(
          isLoading: false,
          error: 'Failed to load anniversaries',
        );
      }
    } catch (e, stacktrace) {
      debugPrint("Error loading anniversaries: $e\n$stacktrace");
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load anniversaries: $e',
      );
    }
  }

  Future<void> loadSocialLinks() async {
    try {
      final response = await ApiClient().get(endpoint: 'api/customer/social-links');

      if (response['status'] == 1) {
        final Map<String, dynamic>? responseData = response['data'] as Map<String, dynamic>?;
        final rawData = responseData?['data'] as Map<String, dynamic>?;
        final socialLinks = rawData != null ? SocialLinksModel.fromJson(rawData) : null;
        
        state = state.copyWith(
          socialLinks: socialLinks,
        );
      }
    } catch (e) {
      debugPrint("Error loading social links: ${e.toString()}");
    }
  }

  Future<void> loadDashboardCounters() async {
    try {
      final response = await ApiClient().get(endpoint: 'api/customer/dashboard-counters');
      if (response['status'] == 1) {
        final Map<String, dynamic>? responseData = response['data'] as Map<String, dynamic>?;
        final countersData = responseData?['counters'] as Map<String, dynamic>?;
        if (countersData != null) {
          final countersModel = DashboardCountersModel.fromJson(countersData);
          state = state.copyWith(dashboardCounters: countersModel);
        }
      }
    } catch (e) {
      debugPrint("Error loading dashboard counters: ${e.toString()}");
    }
  }
}

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
