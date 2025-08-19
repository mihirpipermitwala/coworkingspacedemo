import 'package:flutter/foundation.dart';
import '../models/coworking_space_model.dart';
import '../services/api_service.dart';

class SpaceProvider with ChangeNotifier {
  List<CoworkingSpaceModel> _spaces = [];
  List<CoworkingSpaceModel> _filteredSpaces = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCity;
  double? _maxPrice;

  List<CoworkingSpaceModel> get spaces => _filteredSpaces;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  double? get maxPrice => _maxPrice;

  List<String> get cities {
    return _spaces.map((space) => space.city).toSet().toList()..sort();
  }

  Future<void> loadSpaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _spaces = await ApiService.getCoworkingSpaces();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchSpaces(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCity(String? city) {
    _selectedCity = city;
    _applyFilters();
  }

  void filterByPrice(double? maxPrice) {
    _maxPrice = maxPrice;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCity = null;
    _maxPrice = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredSpaces = _spaces.where((space) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          space.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          space.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          space.location.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCity = _selectedCity == null || space.city == _selectedCity;

      bool matchesPrice = _maxPrice == null || space.pricePerHour <= _maxPrice!;

      return matchesSearch && matchesCity && matchesPrice;
    }).toList();

    notifyListeners();
  }

  CoworkingSpaceModel? getSpaceById(String id) {
    try {
      return _spaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }
}
