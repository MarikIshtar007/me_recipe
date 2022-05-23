import 'package:flutter/foundation.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/db_helper.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:rxdart/rxdart.dart';

enum SearchStatus { SEARCHING, NOT_SEARCHING }

class RecipeViewModel {
  final BehaviorSubject<Resource> _recipes =
      BehaviorSubject.seeded(Resource.loading());

  final BehaviorSubject<Resource> _bookmarkedRecipes =
      BehaviorSubject.seeded(Resource.loading());

  final BehaviorSubject<SearchStatus> _searchStatus =
      BehaviorSubject.seeded(SearchStatus.NOT_SEARCHING);

  BehaviorSubject<SearchStatus> get searchStatus => _searchStatus;
  BehaviorSubject<Resource> get recipes => _recipes;
  BehaviorSubject<Resource> get bookmarkedRecipes => _bookmarkedRecipes;

  SearchStatus _localSearchStatus = SearchStatus.NOT_SEARCHING;
  final List<Recipe> _recipeSearchSnapshot = [];
  final List<Recipe> _importedRecipes = [];

  late final RecipeDatabase recipeDatabase;

  bool _outdated = true;

  RecipeViewModel() {
    recipeDatabase = RecipeDatabase();
    recipeDatabase.init();
    _outdated = true;
  }

  void toggleSearch() {
    if (_localSearchStatus == SearchStatus.NOT_SEARCHING) {
      _localSearchStatus = SearchStatus.SEARCHING;
      _recipeSearchSnapshot.addAll(_recipes.value.data);
    } else {
      _localSearchStatus = SearchStatus.NOT_SEARCHING;
      getRecipes();
      _recipeSearchSnapshot.clear();
    }
    _searchStatus.add(_localSearchStatus);
  }

  bool isSearching() {
    return _localSearchStatus == SearchStatus.SEARCHING;
  }

  void searchRecipes(String queryText) {
    if (_recipes.hasValue) {
      List<Recipe> searchResult = [];
      for (var recipe in _recipeSearchSnapshot) {
        if (recipe.title.contains(queryText)) {
          searchResult.add(recipe);
        }
      }
      _recipes.add(Resource.success(searchResult));
    } else {
      _recipes.add(Resource.failure("Something wrong with search"));
    }
  }

  Future<void> getRecipes() async {
    var response = await recipeDatabase.fetchRecipes();
    _recipes.add(response);
  }

  Future<int> addRecipe(Recipe recipe) async {
    int response = await recipeDatabase.insertRecipe(recipe);
    if (response == kMethodError) {
      return response;
    } else {
      await getRecipes();
      return kMethodSuccess;
    }
  }

  Future<int> editRecipe(Recipe recipe) async {
    int response = await recipeDatabase.editRecipe(recipe);
    if (response == kMethodError) {
      return response;
    } else {
      await getRecipes();
      return kMethodSuccess;
    }
  }

  Future<int> deleteRecipe(Recipe recipe) async {
    int response = await recipeDatabase.deleteRecipe(recipe);
    if (response == kMethodError) {
      return response;
    } else {
      await getRecipes();
      return kMethodSuccess;
    }
  }

  Future<String> exportDatabase() async {
    String dbPath = await recipeDatabase.getDatabasePath();
    return dbPath;
  }

  Future<Resource> fetchImportedRecipes(String dbPath) async {
    Resource response = await recipeDatabase.fetchImportedRecipe(dbPath);
    if (response.status == Status.success) {
      _importedRecipes.clear();
      _importedRecipes.addAll(response.data);
    }
    return response;
  }

  Future<int> overrideDatabase() async {
    if (_importedRecipes.isEmpty) return kMethodError;
    int response = await recipeDatabase.overrideDatabase(_importedRecipes);
    return response;
  }

  Future<int> mergeDatabase() async {
    if (_importedRecipes.isEmpty) return kMethodError;
    int response = await recipeDatabase.mergeDatabase(_importedRecipes);
    return response;
  }

  Future<int> bookmarkRecipe(int id, bool shouldBookmark) async {
    int response = await recipeDatabase.bookmarkRecipe(id, shouldBookmark);
    if (response == kMethodSuccess) {
      List<Recipe> recipeList = recipes.value.data as List<Recipe>;
      for (var recipe in recipeList) {
        if (recipe.id == id) {
          recipe.bookmark = shouldBookmark;
          break;
        }
      }
      _recipes.add(Resource.success(recipeList));
      _outdated = true;
    }
    return response;
  }

  Future<void> getBookmarkedRecipes() async {
    if (_outdated) {
      debugPrint("How many times is this called? ");
      List<Recipe> recipeList = recipes.value.data as List<Recipe>;
      var finalList = recipeList.where((element) => element.bookmark).toList();
      _bookmarkedRecipes.add(Resource.success(finalList));
      _outdated = false;
    }
  }
}
