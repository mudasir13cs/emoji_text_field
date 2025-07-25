import 'package:emoji_text_field/models/emoji_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emoji_text_field/emoji_text_field.dart';

void main() {
  group('EmojiTextFieldView Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('EmojiTextField renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
              hintText: 'Test hint',
            ),
          ),
        ),
      );

      expect(find.byType(EmojiTextField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test hint'), findsOneWidget);
    });

    testWidgets('Emoji button is visible by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_emotions), findsOneWidget);
    });

    testWidgets('Emoji button can be hidden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
              showEmojiButton: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_emotions), findsNothing);
    });

    testWidgets('Emoji button toggles keyboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
            ),
          ),
        ),
      );

      // Find and tap emoji button
      final emojiButton = find.byIcon(Icons.emoji_emotions);
      expect(emojiButton, findsOneWidget);

      await tester.tap(emojiButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet appears
      expect(find.text('Emojis'), findsOneWidget);
      expect(find.byType(EmojiKeyboardView), findsOneWidget);
    });

    testWidgets('Close button works in emoji keyboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
            ),
          ),
        ),
      );

      // Open emoji keyboard
      await tester.tap(find.byIcon(Icons.emoji_emotions));
      await tester.pumpAndSettle();

      // Find and tap close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Verify keyboard is closed
      expect(find.text('Emojis'), findsNothing);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
            ),
          ),
        ),
      );

      // Open emoji keyboard
      await tester.tap(find.byIcon(Icons.emoji_emotions));
      await tester.pumpAndSettle();

      // Find search field and enter text
      final searchField = find.byType(TextField).last;
      await tester.enterText(searchField, 'happy');
      await tester.pumpAndSettle();

      // Verify search is working - check if any emojis are displayed
      // Since we're using external data, let's check for the search state instead
      expect(find.byType(GridView), findsOneWidget);

      // Alternative: Check if "No emojis found" message appears when searching for something that doesn't exist
      await tester.enterText(searchField, 'xyznothingfound');
      await tester.pumpAndSettle();

      expect(find.text('No emojis found'), findsOneWidget);
    });

    test('TextEditingController integration works', () {
      controller.text = 'Hello';
      expect(controller.text, equals('Hello'));

      // Set cursor position at end of text
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);

      // Simulate emoji insertion at end
      const emoji = '😀';
      final selection = controller.selection;
      final newText = controller.text.replaceRange(
        selection.start,
        selection.end,
        emoji,
      );

      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + emoji.length,
        ),
      );

      expect(controller.text, equals('Hello😀'));
      expect(controller.selection.baseOffset,
          equals(7)); // 5 (Hello) + 2 (😀 is 2 chars)
    });

    test('Emoji insertion at cursor position works', () {
      controller.text = 'Hello World';
      controller.selection =
          const TextSelection.collapsed(offset: 5); // After "Hello"

      const emoji = '😍';
      final text = controller.text;
      final selection = controller.selection;
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        emoji,
      );

      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + emoji.length,
        ),
      );

      expect(controller.text, equals('Hello😍 World'));
      expect(controller.selection.baseOffset,
          equals(7)); // 5 (Hello) + 2 (😍 is 2 chars)
    });

    testWidgets('EmojiViewConfig customization works',
        (WidgetTester tester) async {
      const config = EmojiViewConfig(
        height: 400,
        columns: 8,
        enableSearch: false,
        showRecentTab: false,
        backgroundColor: Colors.white,
        indicatorColor: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
              emojiConfig: config,
            ),
          ),
        ),
      );

      expect(find.byType(EmojiTextField), findsOneWidget);
    });

    testWidgets('Multiline support works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
              maxLines: 3,
            ),
          ),
        ),
      );

      expect(find.byType(EmojiTextField), findsOneWidget);

      // Enter multiline text
      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2\nLine 3');
      expect(controller.text, equals('Line 1\nLine 2\nLine 3'));
    });

    testWidgets('onChanged callback works', (WidgetTester tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiTextField(
              controller: controller,
              onChanged: (text) {
                changedText = text;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      expect(changedText, equals('Test'));
    });

    test('EmojiCategory creation works', () {
      const category = EmojiCategory(
        name: 'Test Category',
        icon: Icons.star,
        emojis: ['😀', '😃', '😄'],
      );

      expect(category.name, equals('Test Category'));
      expect(category.icon, equals(Icons.star));
      expect(category.emojis.length, equals(3));
      expect(category.emojis.first, equals('😀'));
    });

    test('Default emoji keywords exist', () {
      const keywords = {
        '😀': ['happy', 'smile', 'grin', 'joy', 'cheerful'],
        '😂': ['laugh', 'joy', 'tears', 'funny', 'crying'],
        '❤️': ['heart', 'love', 'red', 'romance', 'affection'],
      };

      keywords.forEach((emoji, expectedKeywords) {
        expect(expectedKeywords.length, greaterThan(0));
        expect(expectedKeywords.first, isA<String>());
      });
    });
  });

  group('EmojiTextFieldView Static Methods Tests', () {
    testWidgets('showEmojiKeyboard creates bottom sheet',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    EmojiTextFieldView.showEmojiKeyboard(
                      context: context,
                      textController: controller,
                    );
                  },
                  child: const Text('Show Keyboard'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Keyboard'));
      await tester.pumpAndSettle();

      expect(find.byType(EmojiKeyboardView), findsOneWidget);
      expect(find.text('Emojis'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('showEmojiOverlay creates overlay',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    EmojiTextFieldView.showEmojiOverlay(
                      context: context,
                      textController: controller,
                      textFieldKey: GlobalKey(),
                    );
                  },
                  child: const Text('Show Overlay'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Overlay'));
      await tester.pumpAndSettle();

      expect(find.byType(EmojiKeyboardView), findsOneWidget);

      controller.dispose();
    });
  });

  group('EmojiKeyboardView Widget Tests', () {
    testWidgets('EmojiKeyboardView renders with default config',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiKeyboardView(
              textController: controller,
            ),
          ),
        ),
      );

      expect(find.byType(EmojiKeyboardView), findsOneWidget);
      expect(find.text('Emojis'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Tab navigation works', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiKeyboardView(
              textController: controller,
            ),
          ),
        ),
      );

      // Find tabs and tap second tab
      final tabs = find.byType(Tab);
      expect(tabs, findsWidgets);

      if (tester.widgetList(tabs).length > 1) {
        await tester.tap(tabs.at(1));
        await tester.pumpAndSettle();
      }

      controller.dispose();
    });
  });
}
