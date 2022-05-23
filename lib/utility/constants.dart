/// String used throughout the app

const String kFetchRecipeFailure = "There was an error in fetching the recipes";
const String kAddRecipeAppBarText = "Add your own Recipe";
const String kEditRecipeAppBarText = "Edit your Recipe";
const String kEditRecipeMissingData = "Please fill out all details";
const String kSomethingWentWrong = "Something went wrong";
const String kBookmarkedRecipeAppBarText = "Favorites";
const String kEmptyRecipeList =
    "So empty...\n\nAdd your recipes and get started !!";
const String kEmptyRecipeSearchResult = "No matching results";
const String kDatabaseHandleAppBarText = "Import or Export Database";
const String kImportDatabaseText = "Import Someone's shared recipes";
const String kExportDatabaseText = "Share your recipe database with others";
const String kImportDatabaseButtonText = "Import Recipes";
const String kExportDatabaseButtonText = "Export Recipes";
const String kOverrideData = "Override Data";
const String kOverrideConfirmationText =
    "Are you sure you want to override data? This will remove all your existing recipes and is non-reversible. Don't come crying if this fails...";
const String kOverrideFailureText =
    "Override failed. You're lucky if your data survived";
const String kDefeatAccepted = "I accept defeat";
const String kMergeData = "Merge Data";
const String kMergeConfirmationText =
    "Are you sure you want to merge data? This will add the recipes to your existing database. Duplicates may emerge.";
const String kDefeatTitle = "Well well...";
const String kMergeFailureText =
    "Merge failed. Don't blame me if the data is corrupted";
const String kCancelAction = "Cancel";

// Strings for DB CRUD Ops
const String kRecipeDatabaseName = "myrecipes.db";
const String kRecipeTableName = "recipes";
const String kIngredientSeparator = "*";
const String kDbTableIdColumn = "id";
const String kDbTableTitleColumn = "title";
const String kDbTableImageColumn = "image";
const String kDbTableIngredientsColumn = "ingredients";
const String kDbTableProcedureColumn = "procedure";
const String kDbTableBookmarkedColumn = "bookmark";
const int kMethodError = -1;
const int kMethodSuccess = 0;
