import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  late int id;
  late String title;
  late Uint8List? image;
  late List<String> ingredients;
  late String procedure;

  Recipe(this.id, this.title, this.image, this.ingredients, this.procedure);

  @override
  List<Object?> get props => [id, title];

  @override
  String toString() =>
      'Recipe { id: $id, title: $title , ingredients: $ingredients, procedure: $procedure}';

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "image": image,
      "ingredients": ingredients.join("|"),
      "procedure": procedure
    };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    var list = map["ingredients"] as String;
    var ingredientList = list.split("|");
    return Recipe(map["id"] as int, map["title"], map["image"], ingredientList,
        map["procedure"]);
  }
}
