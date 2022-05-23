import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class RecipeDatabase {
  static final RecipeDatabase _instance = RecipeDatabase._();
  static Database? _database;

  RecipeDatabase._();

  factory RecipeDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }

    _database = await init();

    return _database!;
  }

  _onCreate(Database database, int version) async {
    database.execute('''CREATE TABLE IF NOT EXISTS recipes 
        (
        $kDbTableIdColumn INTEGER PRIMARY KEY AUTOINCREMENT,
        $kDbTableTitleColumn TEXT,
        $kDbTableImageColumn BLOB,
        $kDbTableIngredientsColumn TEXT,
        $kDbTableProcedureColumn TEXT,
        $kDbTableBookmarkedColumn BOOLEAN
        );
        ''');
  }

  void deInit() {
    _database = null;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, kRecipeDatabaseName);
    var database = openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return database;
  }

  Future<String> getDatabasePath() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String dbPath = join(directory.path, kRecipeDatabaseName);
      return dbPath;
    } catch (err) {
      debugPrint("Error in getting db path: $err");
      return "";
    }
  }

  Future<Resource> fetchRecipes() async {
    try {
      var client = await db;
      var res = await client.query(kRecipeTableName);
      if (res.isNotEmpty) {
        var recipes = res.map((e) => Recipe.fromMap(e)).toList();
        Resource<List<Recipe>> resource =
            Resource<List<Recipe>>.success(recipes);
        return resource;
      }
      return Resource.success([]);
    } catch (err) {
      debugPrint("Error in fetching recipes: $err");
      return Resource.failure("Error in fetching recipes: $err");
    }
  }

  Future<int> insertRecipe(Recipe recipe) async {
    var client = await db;
    try {
      var res = client.insert(kRecipeTableName, recipe.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return res;
    } catch (e) {
      debugPrint("Error in inserting recipe: $e");
      return kMethodError;
    }
  }

  Future<int> editRecipe(Recipe recipe) async {
    var client = await db;
    try {
      var res = client.update(kRecipeTableName, recipe.toJson(),
          where: "$kDbTableIdColumn = ?",
          whereArgs: [recipe.id],
          conflictAlgorithm: ConflictAlgorithm.replace);
      return res;
    } catch (e) {
      debugPrint("Error in editing recipe: $e");
      return kMethodError;
    }
  }

  Future<int> deleteRecipe(Recipe recipe) async {
    var client = await db;
    try {
      var res = client.delete(kRecipeTableName,
          where: "$kDbTableIdColumn = ?", whereArgs: [recipe.id]);
      return res;
    } catch (e) {
      debugPrint("Error in deleting recipe: $e");
      return kMethodError;
    }
  }

  Future<Resource> fetchImportedRecipe(String path) async {
    var newDb = await openDatabase(path);
    try {
      var res = await newDb.query(kRecipeTableName);
      if (res.isNotEmpty) {
        var recipes = res.map((e) => Recipe.fromMap(e)).toList();
        Resource<List<Recipe>> resource =
            Resource<List<Recipe>>.success(recipes);
        return resource;
      }
      return Resource.success([]);
    } catch (err) {
      debugPrint("Error in fetching imported recipes: $err");
      return Resource.failure("Error in fetching imported recipes: $err");
    }
  }

  Future<int> overrideDatabase(List<Recipe> recipes) async {
    var client = await db;
    try {
      client.delete(kRecipeTableName);
      for (var recipe in recipes) {
        client.insert(kRecipeTableName, recipe.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return kMethodSuccess;
    } catch (err) {
      debugPrint("Error in overriding database: $err");
      return kMethodError;
    }
  }

  Future<int> mergeDatabase(List<Recipe> recipes) async {
    var client = await db;
    try {
      for (var recipe in recipes) {
        client.insert(kRecipeTableName, recipe.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return kMethodSuccess;
    } catch (err) {
      debugPrint("Error in merging database: $err");
      return kMethodError;
    }
  }

  Future<int> bookmarkRecipe(int recipeId, bool shouldBookmark) async {
    var client = await db;
    try {
      client.rawUpdate(
          'UPDATE $kRecipeTableName SET $kDbTableBookmarkedColumn = ? where $kDbTableIdColumn = ?',
          [shouldBookmark, recipeId]);
      return kMethodSuccess;
    } catch (err) {
      debugPrint("Error in bookmarking recipe: $err");
      return kMethodError;
    }
  }

  // Maybe there is a use case where this will be necessary ?
  Future<Resource> getBookmarkedRecipes() async {
    var client = await db;
    try {
      var res = await client.query(kRecipeTableName,
          whereArgs: [1], where: "$kDbTableBookmarkedColumn = ?");
      if (res.isNotEmpty) {
        var recipes = res.map((e) => Recipe.fromMap(e)).toList();
        Resource<List<Recipe>> resource =
            Resource<List<Recipe>>.success(recipes);
        return resource;
      }
      return Resource.success([]);
    } catch (err) {
      debugPrint("Error in fetching recipes: $err");
      return Resource.failure("Error in fetching recipes: $err");
    }
  }
}
