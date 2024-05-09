part of 'home_bloc.dart';

@immutable
sealed class HomeState extends Equatable {
  final bool isPaused;
  final Duration duration;
  final GeoData? geoData;
  final CameraPosition initialPosition;
  final Marker marker;

  final int languageValue;

  const HomeState(
      {this.isPaused = true,
      this.languageValue = 1,
      this.duration = Duration.zero,
      this.geoData,
      required this.initialPosition,
      required this.marker});

  HomeState copyWith(
      {bool? isPaused,
      Duration? duration,
      GeoData? geoData,
      CameraPosition? initialPosition,
      Marker? marker,
      int? languageValue}) {
    return HomeInitial(
        isPaused: isPaused ?? this.isPaused,
        duration: duration ?? this.duration,
        geoData: geoData ?? this.geoData,
        initialPosition: initialPosition ?? this.initialPosition,
        languageValue: languageValue ?? this.languageValue,
        marker: marker ?? this.marker);
  }

  @override
  List<Object?> get props =>
      [isPaused, duration, geoData, initialPosition, marker, languageValue];
}

final class HomeInitial extends HomeState {
  const HomeInitial(
      {super.isPaused,
      super.duration,
      super.geoData,
      super.languageValue,
      required super.initialPosition,
      required super.marker});
}
