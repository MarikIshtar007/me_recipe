import 'package:flutter/material.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/screens/add_recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';
import 'package:me_recipe/widgets/recipe_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RecipeViewModel _viewModel = locator<RecipeViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.only(
              bottom: 3, // space between underline and text
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      Theme.of(context).colorScheme.primary, // Text colour here
                  width: 1.0, // Underline width
                ),
              ),
            ),
            child: Text(
              "My Recipes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.primary, // Text colour here
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: StreamBuilder<Resource>(
            stream: _viewModel.recipes,
            builder: (context, AsyncSnapshot<Resource> snapshot) {
              if (snapshot.data != null) {
                Status status = snapshot.data?.status ?? Status.FAILED;
                switch (status) {
                  case Status.FAILED:
                    return const Center(
                        child: Text(
                      kSomethingWentWrong,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ));
                  case Status.LOADING:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case Status.SUCCESS:
                    List<Recipe> recipes =
                        snapshot.data?.data ?? [] as List<Recipe>;
                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          "So empty...\n\nAdd your recipes and get started !!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            letterSpacing: 0.8,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                Theme.of(context).textTheme.headline5?.fontSize,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 0.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return RecipeTile(recipes[index]);
                      },
                    );
                }
              } else {
                return const Text("Something went really really wrong");
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddRecipeScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
