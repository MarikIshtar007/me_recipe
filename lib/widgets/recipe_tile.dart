import 'package:flutter/material.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/screens/view_recipe.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';

class RecipeTile extends StatelessWidget {
  final Recipe recipe;

  RecipeTile(this.recipe, {Key? key}) : super(key: key);
  final RecipeViewModel viewModel = locator<RecipeViewModel>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ViewRecipe(recipe)));
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Delete",
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: RichText(
                  text: TextSpan(
                    text: "Are you sure you want to delete ",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15),
                    children: [
                      TextSpan(
                          text: recipe.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 15)),
                      const TextSpan(text: " ?"),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      viewModel.deleteRecipe(recipe);
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).errorColor),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  )
                ],
              );
            });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: MediaQuery.of(context).size.height * 0.22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: recipe.image == null
                    ? const AssetImage("assets/default-recipe.png")
                    : MemoryImage(
                        recipe.image!,
                      ) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              recipe.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline6?.fontSize,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
