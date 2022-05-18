import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
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
        $kDbTableProcedureColumn TEXT
        );
        ''');
  }

  void deInit() {
    _database = null;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint(
        'in upgrade --> oldVersion = $oldVersion newVersion = $newVersion');
    deInit();
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, kRecipeDatabaseName);
    var database = openDatabase(dbPath,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return database;
  }

  Future<List<Recipe>?> fetchRecipes() async {
    try {
      var client = await db;
      var res = await client.query(kRecipeTableName);
      if (res.isNotEmpty) {
        var recipes = res.map((e) => Recipe.fromMap(e)).toList();
        return recipes;
      }
      return null;
    } catch (err) {
      debugPrint("Error in fetching recipes: $err");
      return null;
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
}
