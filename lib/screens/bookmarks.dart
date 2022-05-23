import 'package:flutter/material.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';
import 'package:me_recipe/widgets/recipe_tile.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final RecipeViewModel _viewModel = locator<RecipeViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.getBookmarkedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text(kBookmarkedRecipeAppBarText),
          elevation: 0.0,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: StreamBuilder<Resource>(
            stream: _viewModel.bookmarkedRecipes,
            builder: (context, AsyncSnapshot<Resource> snapshot) {
              if (snapshot.data != null) {
                Status status = snapshot.data?.status ?? Status.failed;
                switch (status) {
                  case Status.failed:
                    return Center(
                      child: Text(
                        snapshot.data?.errorMessage ?? kSomethingWentWrong,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  case Status.loading:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case Status.success:
                    List recipes = snapshot.data?.data ?? [];
                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          kEmptyRecipeList,
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
                        return RecipeTile(recipes[index] as Recipe);
                      },
                    );
                }
              } else {
                return const Text("Something went really really wrong");
              }
            },
          ),
        ),
      ),
    );
  }
}
