import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/service/api/api_client/api_client.dart';

import '../model/event_model.dart';

class EventsState {
  final bool isLoading;
  final bool isSaving;
  final bool isLoaded;
  final String? error;
  final List<Event> eventsList;
  final List<Event> upcomingEvents;
  final List<Event> pastEvents;
  final Event? selectedEvent;

  const EventsState({
    this.isLoading = false,
    this.isSaving = false,
    this.isLoaded = false,
    this.error,
    this.eventsList = const [],
    this.upcomingEvents = const [],
    this.pastEvents = const [],
    this.selectedEvent,
  });

  EventsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isLoaded,
    String? error,
    List<Event>? eventsList,
    List<Event>? upcomingEvents,
    List<Event>? pastEvents,
    Event? selectedEvent,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error,
      eventsList: eventsList ?? this.eventsList,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      pastEvents: pastEvents ?? this.pastEvents,
      selectedEvent: selectedEvent ?? this.selectedEvent,
    );
  }
}

class EventsNotifier extends Notifier<EventsState> {
  @override
  EventsState build() {
    return const EventsState();
  }

  Future<void> loadEvents() async {
    state = state.copyWith(
      isLoading: true,
      isLoaded: false,
      error: null,
    );

    try {
      final response = await ApiClient().get(endpoint: 'api/customer/event');

      if (response["status"] == 1) {
        debugPrint("RAW RESPONSE: $response");

        final dynamic upcomingRaw = response['data']?['data']?['upcoming_events'];
        final dynamic pastRaw = response['data']?['data']?['past_events'];

        List<Event> upcoming = [];
        List<Event> past = [];

        if (upcomingRaw != null && upcomingRaw is List) {
          upcoming = upcomingRaw.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        }

        if (pastRaw != null && pastRaw is List) {
          past = pastRaw.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
        }

        final events = [...upcoming, ...past];

        state = state.copyWith(
          isLoading: false,
          isLoaded: true,
          eventsList: events,
          upcomingEvents: upcoming,
          pastEvents: past,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Server returned error status',
        );
      }
    } catch (e, s) {
      debugPrint("EVENT LOAD ERROR: $e");
      debugPrint(s.toString());

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load events',
      );
    }
  }

  Future<void> updateRSVP(
      String memberId,
      Map<String, dynamic> payload) async {

    state = state.copyWith(isSaving: true, error: null);

    try {
      final response = await ApiClient().post(
        endpoint: 'api/customer/event/$memberId/rsvp',
        body: payload,
      );

      if (response != null && response['status'] == 1) {
        await loadEvents();
        state = state.copyWith(isSaving: false, error: null);
      } else {
        throw Exception(response['message'] ?? 'Update failed');
      }
    } catch (e) {
      debugPrint("UPDATE EVENT ERROR: $e");
      state = state.copyWith(
          isSaving: false,
          error: 'Failed to update RSVP'
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final eventsNotifierProvider = NotifierProvider<EventsNotifier, EventsState>(() {
  return EventsNotifier();
});
