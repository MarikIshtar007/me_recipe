import 'package:flutter/material.dart';
import 'package:me_recipe/utility/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController feedbackController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (FocusManager.instance.primaryFocus!.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text(kSendFeedbackAppBarText),
            elevation: 0.0,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  TextFormField(
                    controller: titleController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return kFeedbackTitleEmptyError;
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText: "Title",
                        border: OutlineInputBorder()),
                    maxLines: 1,
                    maxLength: 25,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    minLines: 4,
                    maxLines: 8,
                    controller: feedbackController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: "Describe your issue or feedback",
                        label: const Text("Feedback"),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await submitFeedback(
                              titleController.text, feedbackController.text);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        primary: Colors.white,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> submitFeedback(String title, String feedback) async {
  final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ajmalali2004@gmail.com',
      query: "subject=$title&body=$feedback");
  launchUrl(emailLaunchUri);

  if (await canLaunchUrl(emailLaunchUri)) {
    launchUrl(emailLaunchUri);
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
