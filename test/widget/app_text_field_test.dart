import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/utils/validators.dart';
import 'package:timer/widgets/app_text_field.dart';
import 'package:timer/widgets/primary_button.dart';

void main() {
  testWidgets('AppTextField surfaces the validator message on submit', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: controller,
                  label: 'Email',
                  validator: Validators.email,
                ),
                PrimaryButton(
                  label: 'Submit',
                  onPressed: () => formKey.currentState!.validate(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email is required'), findsNothing);

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsNothing);
  });
}
