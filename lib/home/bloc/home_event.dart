part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();
}

class HomeInitialEvent extends HomeEvent {
  const HomeInitialEvent();
}

class OnButtonStartEvent extends HomeEvent {
  const OnButtonStartEvent();
}

class HomeLoadEvent extends HomeEvent {
  const HomeLoadEvent();
}

class OnButtonStopEvent extends HomeEvent {
  const OnButtonStopEvent();
}

class UpdateTimeEvent extends HomeEvent {
  final Duration duration;

  const UpdateTimeEvent(this.duration);
}

class UpdateGeoDataEvent extends HomeEvent {}

class RefreshEvent extends HomeEvent {}

class ChangeLocaleEvent extends HomeEvent {
  final int value;

  const ChangeLocaleEvent({required this.value});
}
