import 'package:flutter/foundation.dart';

import '../../recipes/data/recipe_repository.dart';
import '../../recipes/models/recipe.dart';

/// UI states of the Home screen recipe list.
enum HomeStatus { loading, success, error, empty }

/// Owns the Home screen's UI state (list status + selected tab) and talks
/// to the data layer through [RecipeRepository] — injected via constructor.
class HomeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  HomeViewModel({required this._repository});

  HomeStatus _status = HomeStatus.loading;
  List<Recipe> _recipes = const [];
  String? _errorMessage;
  int _selectedTabIndex = 0;

  HomeStatus get status => _status;
  List<Recipe> get recipes => _recipes;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;

  Future<void> loadRecipes() async {
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.getRecipes();
      _recipes = result;
      _status = result.isEmpty ? HomeStatus.empty : HomeStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = HomeStatus.error;
    }
    notifyListeners();
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}
