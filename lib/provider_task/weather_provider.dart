// providers/weather_provider.dart
import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cambia a loadWeather sin parámetros o con valores fijos
  Future<void> loadWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Usa lat/lon fijos para evitar geolocalización
      final data = await _weatherService.fetchWeatherByLocation(20.5888, -100.3899);
      _weatherData = data;
    } catch (e) {
      _errorMessage = 'No se pudo obtener el clima';
    }

    _isLoading = false;
    notifyListeners();
  }
}
