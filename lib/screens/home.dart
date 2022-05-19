import 'dart:async';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _viewModel.getRecipes();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _viewModel.searchRecipes(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              children: [
                DrawerHeader(
                  padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "My Recipes",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontSize: 24,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  title: Text(
                    "Import / Export Database",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.data_exploration_outlined,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  title: Text(
                    "Favorites",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.bookmark_outline,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.secondary),
          title: StreamBuilder(
            stream: _viewModel.searchStatus,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == SearchStatus.NOT_SEARCHING) {
                  return Container(
                    padding: const EdgeInsets.only(
                      bottom: 3, // space between underline and text
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Text colour here
                          width: 1.0, // Underline width
                        ),
                      ),
                    ),
                    child: Text(
                      "My Recipes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Text colour here
                      ),
                    ),
                  );
                } else {
                  return TextField(
                    autofocus: true,
                    onChanged: _onSearchChanged,
                  );
                }
              } else {
                return Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).errorColor,
                );
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                _viewModel.toggleSearch();
              },
              icon: StreamBuilder(
                stream: _viewModel.searchStatus,
                builder: (context, AsyncSnapshot<SearchStatus> snapshot) {
                  if (snapshot.data != null) {
                    if (snapshot.data == SearchStatus.SEARCHING) {
                      return Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      );
                    } else {
                      return Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      );
                    }
                  } else {
                    return Icon(
                      Icons.error_outline_rounded,
                      color: Theme.of(context).errorColor,
                    );
                  }
                },
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
              FocusManager.instance.primaryFocus?.unfocus();
              if (_viewModel.isSearching()) {
                _viewModel.toggleSearch();
              }
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
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
                            _viewModel.isSearching()
                                ? kEmptyRecipeSearchResult
                                : kEmptyRecipeList,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 0.8,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  ?.fontSize,
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
