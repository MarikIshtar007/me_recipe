import 'package:flutter/foundation.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/db_helper.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:rxdart/rxdart.dart';

class RecipeViewModel {
  final BehaviorSubject<Resource> _recipes =
      BehaviorSubject.seeded(Resource.loading());

  BehaviorSubject<Resource> get recipes => _recipes;
  late final RecipeDatabase recipeDatabase;

  RecipeViewModel() {
    recipeDatabase = RecipeDatabase();
    recipeDatabase.init();
  }

  Future<void> getRecipes() async {
    var list = await recipeDatabase.fetchRecipes();
    if (list != null) {
      Resource resource = Resource<List<Recipe>>.success(list);
      _recipes.add(resource);
    } else {
      _recipes.add(Resource.failure(kFetchRecipeFailure));
    }
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
      debugPrint("Recipe edited: $recipe");
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
}
