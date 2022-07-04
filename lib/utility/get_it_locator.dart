import 'package:get_it/get_it.dart';
import 'package:me_recipe/viewmodels/ad_state_viewmodel.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => RecipeViewModel());
  locator.registerLazySingleton(() => AdState());
}
