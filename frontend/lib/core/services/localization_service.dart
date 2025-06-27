import 'package:flutter/material.dart';

class LocalizationService {
  static const Locale _defaultLocale = Locale('en', 'US');
  static Locale _currentLocale = _defaultLocale;
  
  static const List<Locale> _supportedLocales = [
    Locale('en', 'US'),
    Locale('rw', 'RW'), // Kinyarwanda
    Locale('fr', 'FR'), // French
  ];

  static Locale get currentLocale => _currentLocale;
  static List<Locale> get supportedLocales => _supportedLocales;

  static Future<void> initialize() async {
    // TODO: Load saved locale from shared preferences
    _currentLocale = _defaultLocale;
  }

  static Future<void> setLocale(Locale locale) async {
    if (_supportedLocales.contains(locale)) {
      _currentLocale = locale;
      // TODO: Save locale to shared preferences
    }
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'rw':
        return 'Kinyarwanda';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  static String getCountryName(String countryCode) {
    switch (countryCode) {
      case 'US':
        return 'United States';
      case 'RW':
        return 'Rwanda';
      case 'FR':
        return 'France';
      default:
        return 'United States';
    }
  }
} 