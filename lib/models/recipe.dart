import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:me_recipe/utility/constants.dart';

class Recipe extends Equatable {
  late int id;
  late String title;
  late Uint8List? image;
  late List<String> ingredients;
  late String procedure;
  late bool bookmark;

  Recipe(this.id, this.title, this.image, this.ingredients, this.procedure,
      this.bookmark);

  @override
  List<Object?> get props => [id, title];

  @override
  String toString() =>
      'Recipe { id: $id, title: $title , ingredients: $ingredients, procedure: $procedure, bookmark: $bookmark imageBytes: $image}';

  Map<String, dynamic> toJson() {
    return {
      kDbTableTitleColumn: title,
      kDbTableImageColumn: image,
      kDbTableIngredientsColumn: ingredients.join("|"),
      kDbTableProcedureColumn: procedure,
      kDbTableBookmarkedColumn: bookmark
    };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    var list = map[kDbTableIngredientsColumn] as String;
    var ingredientList = list.split("|");
    return Recipe(
        map[kDbTableIdColumn] as int,
        map[kDbTableTitleColumn],
        map[kDbTableImageColumn],
        ingredientList,
        map[kDbTableProcedureColumn],
        map[kDbTableBookmarkedColumn] == 1);
  }
}
