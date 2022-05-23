import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/utility/resource.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

import 'home.dart';

class ImportExportDb extends StatefulWidget {
  const ImportExportDb({Key? key}) : super(key: key);

  @override
  State<ImportExportDb> createState() => _ImportExportDbState();
}

class _ImportExportDbState extends State<ImportExportDb> {
  final RecipeViewModel _viewModel = locator<RecipeViewModel>();
  List<Recipe> importedRecipes = [];

  static final loaderDialog = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
          margin: const EdgeInsets.only(left: 7),
          child: const Text("Loading..."),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text(kDatabaseHandleAppBarText),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            kImportDatabaseText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();
                              var path = result?.files.single.path ?? "";
                              if (path.isNotEmpty) {
                                if (path.contains(".db")) {
                                  Resource resource = await _viewModel
                                      .fetchImportedRecipes(path);
                                  if (resource.status == Status.failed) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(resource.errorMessage ??
                                          "Error occurred"),
                                    ));
                                  } else if (resource.status ==
                                      Status.success) {
                                    setState(() {
                                      importedRecipes.clear();
                                      importedRecipes.addAll(resource.data);
                                    });
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Please select files with .db extension")));
                                }
                              }
                            },
                            child: const Text(
                              kImportDatabaseButtonText,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1.5,
                    indent: 25,
                    endIndent: 25,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          kExportDatabaseText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return loaderDialog;
                                });
                            String dbPath = await _viewModel.exportDatabase();
                            Navigator.of(context).pop();
                            if (dbPath.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(kSomethingWentWrong),
                                ),
                              );
                            } else {
                              await Share.shareFiles([dbPath],
                                  text: "Check out my cool Recipes!!");
                            }
                          },
                          child: const Text(
                            kExportDatabaseButtonText,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Text(
              importedRecipes.isNotEmpty ? "Imported Recipes" : "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Expanded(
              flex: 3,
              child: Visibility(
                visible: true,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: importedRecipes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: importedRecipes[index].image == null
                            ? Image.asset(
                                "assets/default-recipe.png",
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                importedRecipes[index].image!,
                                fit: BoxFit.cover,
                              ),
                        title: Text(importedRecipes[index].title),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Visibility(
                visible: importedRecipes.isNotEmpty,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  kOverrideData,
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                content: const Text(kOverrideConfirmationText),
                                actions: [
                                  TextButton(
                                    child: const Text("Override"),
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            return loaderDialog;
                                          });
                                      int response =
                                          await _viewModel.overrideDatabase();
                                      // For removing the loader
                                      Navigator.of(context).pop();
                                      if (response == kMethodSuccess) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        const Home()),
                                                (route) => false);
                                      } else {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(kDefeatTitle),
                                            content: const Text(
                                              kOverrideFailureText,
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  kDefeatAccepted,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const Home()),
                                                          (route) => false);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(kCancelAction),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            });
                      },
                      child: const Text(
                        kOverrideData,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  kMergeData,
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                content: const Text(kMergeConfirmationText),
                                actions: [
                                  TextButton(
                                    child: const Text("Merge"),
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            return loaderDialog;
                                          });
                                      int response =
                                          await _viewModel.mergeDatabase();
                                      Navigator.of(context).pop();
                                      if (response == kMethodSuccess) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        const Home()),
                                                (route) => false);
                                      } else {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(kDefeatTitle),
                                            content:
                                                const Text(kMergeFailureText),
                                            actions: [
                                              TextButton(
                                                child:
                                                    const Text(kDefeatAccepted),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const Home()),
                                                          (route) => false);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(kCancelAction),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            });
                      },
                      child: const Text(
                        'Merge Data',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
