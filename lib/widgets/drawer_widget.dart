import 'package:flutter/material.dart';
import 'package:me_recipe/screens/bookmarks.dart';
import 'package:me_recipe/screens/import_export_db.dart';
import 'package:me_recipe/screens/send_feedback.dart';
import 'package:me_recipe/utility/constants.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  kAppName,
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
            DrawerTile(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const ImportExportDb();
                }));
              },
              title: kDatabaseHandleAppBarText,
              icon: Icon(
                Icons.data_exploration_outlined,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            DrawerTile(
              title: kBookmarkedRecipeAppBarText,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BookmarkScreen()));
              },
              icon: Icon(
                Icons.bookmark_outline,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            DrawerTile(
              title: kSendFeedbackAppBarText,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SendFeedbackScreen()));
              },
              icon: Icon(
                Icons.feedback_outlined,
                color: Theme.of(context).colorScheme.background,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final Function() onTap;
  final String title;
  final Icon icon;
  const DrawerTile(
      {required this.title, required this.onTap, required this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: icon,
      ),
    );
  }
}
