import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:me_recipe/models/recipe.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:me_recipe/utility/get_it_locator.dart';
import 'package:me_recipe/viewmodels/recipe_viewmodel.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddRecipeScreen({Key? key, this.recipe}) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? imageBytes;
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController procedureController = TextEditingController();

  final List<IngredientControllers> ingredientControllers = [];

  final RecipeViewModel viewModel = locator<RecipeViewModel>();
  String appBarText = kAddRecipeAppBarText;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      setupUiForEdit();
    });
  }

  void setupUiForEdit() {
    if (widget.recipe != null) {
      Recipe recipe = widget.recipe!;
      appBarText = kEditRecipeAppBarText;
      imageBytes = recipe.image;
      recipeNameController.text = recipe.title;
      for (var ingredient in recipe.ingredients) {
        List<String> splitIngredients =
            ingredient.split(kIngredientQuantitySeparator);
        ingredientControllers.add(IngredientControllers(
          TextEditingController()..text = splitIngredients.first,
          TextEditingController()..text = splitIngredients.last,
        ));
      }
      procedureController.text = recipe.procedure;
    } else {
      ingredientControllers.add(IngredientControllers(
          TextEditingController(), TextEditingController()));
    }
    setState(() {});
  }

  Widget buildGeneralTextField(
      String label, TextEditingController textEditingController) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 5),
      child: TextField(
        controller: textEditingController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]")),
        ],
        decoration: InputDecoration(
          label: Text(label),
          hintText: "Add $label",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget buildIngredientCard(IngredientControllers controllers, int index) {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.0,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 2.0, left: 6.0, right: 6.0, bottom: 2.0),
        child: Row(
          children: [
            buildIngredientNameField(controllers.name),
            buildIngredientQuantityField(controllers.quantity),
            IconButton(
              onPressed: () {
                setState(() {
                  ingredientControllers.removeAt(index);
                });
              },
              icon: Icon(
                Icons.remove_circle_outline,
                color: Theme.of(context).errorColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildIngredientNameField(TextEditingController textEditingController) {
    return Expanded(
        child: buildGeneralTextField("Ingredient", textEditingController));
  }

  Widget buildIngredientQuantityField(
      TextEditingController textEditingController) {
    return Expanded(
      child: buildGeneralTextField("Quantity", textEditingController),
    );
  }

  bool recipeValidation() {
    if (recipeNameController.text.isEmpty) return false;
    for (var s in ingredientControllers) {
      if (s.name.text.isEmpty || s.quantity.text.isEmpty) {
        return false;
      }
    }
    if (procedureController.text.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          appBarText,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (recipeValidation()) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          Text("Loading"),
                        ],
                      ),
                    );
                  },
                );
                String recipeName = recipeNameController.text;
                Uint8List? imageAsBytes = imageBytes;
                List<String> ingredients = [];
                for (var controller in ingredientControllers) {
                  ingredients.add(
                      "${controller.name.text}$kIngredientQuantitySeparator${controller.quantity.text}");
                }
                String procedure = procedureController.text;

                int response = -1;
                if (widget.recipe != null) {
                  Recipe recipe = Recipe(
                      widget.recipe!.id,
                      recipeName,
                      imageAsBytes,
                      ingredients,
                      procedure,
                      widget.recipe!.bookmark);
                  response = await viewModel.editRecipe(recipe);
                } else {
                  Recipe recipe = Recipe(0, recipeName, imageAsBytes,
                      ingredients, procedure, false);
                  response = await viewModel.addRecipe(recipe);
                }
                Navigator.of(context).pop();
                if (response != -1) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Successfully Added"),
                  ));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Something went wrong"),
                  ));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(kEditRecipeMissingData),
                ));
              }
            },
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) {
                          imageBytes = await image.readAsBytes();
                          setState(() {});
                        }
                      },
                      child: CircleAvatar(
                        radius: size.height * 0.07,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            Text("Recipe Image")
                          ],
                        ),
                        foregroundImage: getImageDisplay(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: recipeNameController,
                          style: const TextStyle(fontSize: 18.0),
                          decoration: const InputDecoration(
                            label: Text("Recipe Name"),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12.0),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ingredientControllers.length,
                    itemBuilder: (context, index) {
                      return buildIngredientCard(
                          ingredientControllers[index], index);
                    },
                  ),
                ),
                TextButton(
                  child: const Text("Add Ingredient"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        ingredientControllers.add(
                          IngredientControllers(
                            TextEditingController(),
                            TextEditingController(),
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    minLines: 4,
                    maxLines: 8,
                    controller: procedureController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: "Enter Recipe Procedure",
                        label: const Text("Procedure"),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MemoryImage? getImageDisplay() {
    if (imageBytes == null) return null;
    return MemoryImage(imageBytes!);
  }
}

class IngredientControllers {
  final TextEditingController name;
  final TextEditingController quantity;

  IngredientControllers(this.name, this.quantity);
}
