import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:weather_app_new/constants/constants.dart';
import 'package:weather_app_new/models/hourly_weather.dart';
import 'package:weather_app_new/models/weather.dart';
import 'package:weather_app_new/models/weekly_weather.dart';
import 'package:weather_app_new/services/geolocator.dart';
import 'package:weather_app_new/utils/logging.dart';

@immutable
class ApiHelper {
  static const String baseURL = "https://api.openweathermap.org/data/2.5";
  static const String weeklyWeatherURL =
      "https://api.open-meteo.com/v1/forecast&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto";

  static double lat = 0.0;
  static double lon = 0.0;
  static final dio = Dio();

  static Future<void> fetchLocation() async {
    final location = await getLocation();

    lat = location.latitude;
    lon = location.longitude;
  }

  // gettting Current weather
  static Future<Weather> getCurrentWeather() async {
    await fetchLocation();
    final url = _constructWeatherURL();
    final response = await _fetchData(url);

    return Weather.fromJson(response);
  }

  // getting hourly forecast
  static Future<HourlyWeather> getHourlyForecast() async {
    await fetchLocation();
    final url = _constructForecastURL();
    final response = await _fetchData(url);

    return HourlyWeather.fromJson(response);
  }

  // getting weekly forecast
  static Future<WeeklyWeather> getWeeklyForecast() async {
    await fetchLocation();
    final url = _constructWeeklyForecastURL();
    final response = await _fetchData(url);

    return WeeklyWeather.fromJson(response);
  }

  // getting current weather by city name
  static Future<Weather> getWeatherByCityName({
    required String cityName,
  }) async {
    final url = _constructWeatherByCityURL(cityName);
    final response = await _fetchData(url);

    return Weather.fromJson(response);
  }

  static String _constructWeatherURL() =>
      "$baseURL/weather?lat=$lat&lon=$lon&units=metric&appid=${Constants.apiKey}";
  static String _constructForecastURL() =>
      "$baseURL/forecast?lat=$lat&lon=$lon&units=metric&appid=${Constants.apiKey}";
  static String _constructWeatherByCityURL(String cityName) =>
      "$baseURL/weather?q=$cityName&units=metric&appid=${Constants.apiKey}";
  static String _constructWeeklyForecastURL() =>
      "$weeklyWeatherURL&latitude=$lat&longitude=$lon";

  static Future<Map<String, dynamic>> _fetchData(String url) async {
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        printWarning("Failed to load data: ${response.statusCode}");
        throw Exception("Failed to load data.");
      }
    } catch (e) {
      printWarning("Error fetching data from $url: $e");
      throw Exception("Error fetching data.");
    }
  }
}
