import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/screens/add_recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:me_recipe/utility/secrets.dart';
import 'package:me_recipe/viewmodels/ad_state_viewmodel.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';
import 'package:me_recipe/widgets/drawer_widget.dart';
import 'package:me_recipe/widgets/recipe_tile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RecipeViewModel _viewModel = locator<RecipeViewModel>();
  final AdState _adState = locator<AdState>();
  Timer? _debounce;

  AdWithView? adWithView;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _adState.initialization.then((value) {
      setState(() {
        adWithView = BannerAd(
            adUnitId: adMobBannerID,
            size: AdSize.banner,
            request: AdRequest(),
            listener: _adState.adListener)
          ..load();
      });
    });
  }

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
        drawer: const DrawerWidget(),
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
                if (snapshot.data == SearchStatus.notSearching) {
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
                    if (snapshot.data == SearchStatus.searching) {
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
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (_viewModel.isSearching()) {
                      _viewModel.toggleSearch();
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 15.0),
                  child: StreamBuilder<Resource>(
                    stream: _viewModel.recipes,
                    builder: (context, AsyncSnapshot<Resource> snapshot) {
                      if (snapshot.data != null) {
                        Status status = snapshot.data?.status ?? Status.failed;
                        switch (status) {
                          case Status.failed:
                            return Center(
                              child: Text(
                                snapshot.data?.errorMessage ??
                                    kSomethingWentWrong,
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
                                  _viewModel.isSearching()
                                      ? kEmptyRecipeSearchResult
                                      : kEmptyRecipeList,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    letterSpacing: 0.8,
                                    fontStyle: FontStyle.italic,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
            ),
            if (adWithView == null)
              const SizedBox(
                height: 50,
              )
            else
              SizedBox(
                height: 50,
                child: AdWidget(
                  ad: adWithView!,
                ),
              )
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton(
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
      ),
    );
  }
}
