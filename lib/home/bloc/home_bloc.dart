import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_task/geo_data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Timer? timer;
  Stopwatch stopwatch = Stopwatch();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  HomeBloc()
      : super(const HomeInitial(
            marker: Marker(markerId: MarkerId('1')),
            initialPosition: CameraPosition(target: LatLng(0, 0)))) {
    on<HomeEvent>((event, emit) async {});

    on<HomeLoadEvent>((event, emit) async {
      SharedPreferences preferences = await _prefs;
      try {
        GeoData? data = await queryIPData();

        if (data != null) {
          debugPrint('Fetched new data from service');
          preferences.setString('city', data.city);
          preferences.setString('country', data.country);
          preferences.setString('countryCode', data.countryCode);
          preferences.setString('ip', data.ip);
          preferences.setString('timezone', data.timezone);
          preferences.setDouble('latitude', data.latitude);
          preferences.setDouble('longitude', data.longitude);
          debugPrint('Data have been written into storage');
        } else {
          if (preferences.containsKey('ip')) {
            var city = preferences.getString('city') ?? 'Dnipro';
            var country = preferences.getString('country') ?? 'Ukraine';
            var countryCode = preferences.getString('countryCode') ?? 'UA';
            var ip = preferences.getString('ip') ?? '0.0.0.0';
            var timezone = preferences.getString('timezone') ?? 'Z+1';
            var latitude = preferences.getDouble('latitude') ?? 0.0;
            var longitude = preferences.getDouble('longitude') ?? 0.0;
            emit(state.copyWith(
                geoData: GeoData(latitude, longitude, country, countryCode,
                    city, timezone, ip)));
          }

          debugPrint('Data have been read from storage');
        }

        emit(state.copyWith(geoData: data));
        CameraPosition initialPosition = CameraPosition(
          target: LatLng(state.geoData!.latitude, state.geoData!.longitude),
          zoom: 15,
        );

        Marker marker = Marker(
          markerId: const MarkerId('geo_marker'),
          position: LatLng(state.geoData!.latitude, state.geoData!.longitude),
          infoWindow: InfoWindow(
              title: '${state.geoData!.city}, ${state.geoData!.country}'),
        );
        emit(state.copyWith(initialPosition: initialPosition, marker: marker));
      } on Exception catch (e) {
        log(e.toString());
      }
    });

    on<OnButtonStartEvent>((event, emit) async {
      if (timer == null || !timer!.isActive) {
        stopwatch.start();
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          add(UpdateTimeEvent(stopwatch.elapsed));
        });
        emit(state.copyWith(isPaused: false));
      }
    });

    on<OnButtonStopEvent>((event, emit) {
      stopwatch.stop();
      stopwatch.reset();
      timer?.cancel();
      emit(state.copyWith(duration: Duration.zero));
      emit(state.copyWith(isPaused: true));
    });

    on<UpdateTimeEvent>((event, emit) {
      emit(state.copyWith(duration: event.duration));
    });

    on<UpdateGeoDataEvent>((event, emit) {});

    on<ChangeLocaleEvent>((event, emit) {
      emit(state.copyWith(languageValue: event.value));
    });

    on<RefreshEvent>((event, emit) async {
      GeoData? data = await queryIPData();

      if (data != null) {
        debugPrint('Fetched new data from service');
        emit(state.copyWith(geoData: data));
      } else {
        final SharedPreferences prefs = await _prefs;

        if (prefs.containsKey('ip')) {
          var city = prefs.getString('city') ?? 'Dnipro';
          var country = prefs.getString('country') ?? 'Ukraine';
          var countryCode = prefs.getString('countryCode') ?? 'UA';
          var ip = prefs.getString('ip') ?? '0.0.0.0';
          var timezone = prefs.getString('timezone') ?? 'Z+1';
          var latitude = prefs.getDouble('latitude') ?? 0.0;
          var longitude = prefs.getDouble('longitude') ?? 0.0;
          emit(state.copyWith(
              geoData: GeoData(latitude, longitude, country, countryCode, city,
                  timezone, ip)));
        }

        debugPrint('Data have been read from storage');
      }
    });
  }

  @override
  Future<void> close() {
    timer?.cancel();
    stopwatch.stop();
    return super.close();
  }
}

Future<GeoData?> queryIPData() async {
  try {
    var response = await http.get(Uri.http('ip-api.com', 'json'));
    if (response.statusCode == 200) {
      Map<String, dynamic> decodedMap =
          jsonDecode(response.body) as Map<String, dynamic>;
      return GeoData.fromJson(decodedMap);
    }
  } on Exception {
    return null;
  }
  return null;
}
