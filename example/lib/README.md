# Emoji Text Field Example

This example demonstrates how to use the `emoji_text_field` plugin in your Flutter applications.

## Features Demonstrated

### 1. Enhanced TextField
- TextField with built-in emoji button
- Automatic emoji insertion at cursor position
- Real-time text updates

### 2. Multiline Support
- Perfect for comments, posts, and long-form text
- Maintains cursor position across multiple lines
- Responsive layout adaptation

### 3. Custom Configuration
- Customized picker height and appearance
- Custom colors and styling
- Configurable column count and search behavior

### 4. Manual Controls
- Programmatic emoji picker triggering
- Bottom sheet and overlay display modes
- Integration with existing TextFields

### 5. Live Preview
- Real-time display of entered text with emojis
- Visual feedback for user interactions
- Multiple text field demonstrations

## How to Run

```bash
cd example
flutter pub get
flutter run
```

## Key Integration Points

### Basic Usage
```dart
EmojiTextField(
  controller: textController,
  hintText: 'Type a message...',
)
```

### Custom Configuration
```dart
EmojiTextField(
  controller: textController,
  emojiConfig: EmojiViewConfig(
    height: 350,
    backgroundColor: Colors.grey[100],
    indicatorColor: Colors.purple,
    columns: 8,
  ),
)
```

### Manual Control
```dart
EmojiTextFieldView.showEmojiKeyboard(
  context: context,
  textController: textController,
);
```

## Screenshots

The example app includes:
- Multiple TextField demonstrations
- Feature showcase with icons and descriptions
- Live preview of text with emojis
- Professional UI design with cards and shadows
- Responsive layout for different screen sizes

## Next Steps

After exploring this example, you can:
1. Copy the integration patterns to your own app
2. Customize the emoji picker configuration
3. Add your own emoji categories and keywords
4. Implement persistence for recent emojis

For more information, check the main plugin documentation.