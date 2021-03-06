import 'package:flutter/material.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/screens/add_recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';
import 'package:me_recipe/widgets/ingredient_tile_widget.dart';

class ViewRecipe extends StatefulWidget {
  final Recipe recipe;

  const ViewRecipe(this.recipe, {Key? key}) : super(key: key);

  @override
  State<ViewRecipe> createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
  List<String> procedureList = [];
  var selectedProcedureIdx = 0;
  bool isBookMark = false;

  final RecipeViewModel _viewModel = locator<RecipeViewModel>();

  @override
  void initState() {
    super.initState();
    isBookMark = widget.recipe.bookmark;
    procedureList.addAll(widget.recipe.procedure.split("\n"));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.background,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => AddRecipeScreen(recipe: widget.recipe)));
          },
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.3,
                stretch: true,
                stretchTriggerOffset: 10.0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle
                  ],
                  background: widget.recipe.image == null
                      ? Image.asset(
                          "assets/default-recipe.png",
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          widget.recipe.image!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              widget.recipe.title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    ?.fontSize,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          StatefulBuilder(
                            builder: (context, setThisState) {
                              return GestureDetector(
                                onTap: () async {
                                  int response =
                                      await _viewModel.bookmarkRecipe(
                                          widget.recipe.id, !isBookMark);
                                  if (response == kMethodSuccess) {
                                    setThisState(() {
                                      isBookMark = !isBookMark;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Failed... Congrats! You broke the app."),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    isBookMark
                                        ? Icons.bookmark
                                        : Icons.bookmark_outline,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 16.0,
                          bottom: 5.0,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "INGREDIENTS",
                            style: TextStyle(
                              letterSpacing: 1.0,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.fontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    widget.recipe.ingredients.length,
                    (index) {
                      var ingredients = widget.recipe.ingredients[index]
                          .split(kIngredientQuantitySeparator);
                      return IngredientTile(ingredients);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(
                        color: Theme.of(context).colorScheme.primary,
                        thickness: 2.5,
                        indent: 25.0,
                        endIndent: 25.0,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "PROCEDURE",
                          style: TextStyle(
                            letterSpacing: 1.0,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                Theme.of(context).textTheme.bodyText1?.fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    procedureList.length,
                    (index) => ListTile(
                      onTap: () {
                        setState(() {
                          selectedProcedureIdx = index;
                        });
                      },
                      minVerticalPadding: 15.0,
                      title: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: selectedProcedureIdx == index
                            ? TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary)
                            : TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5)),
                        child: Text(procedureList[index]),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedProcedureIdx == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(6.0),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          child: Text((index + 1).toString()),
                          style: selectedProcedureIdx == index
                              ? TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16.0)
                              : TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.6),
                                  fontSize: 8.0,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
