import 'package:flutter/material.dart';
import 'package:emoji_text_field/emoji_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Text Field Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const EmojiTextFieldExample(),
    );
  }
}

class EmojiTextFieldExample extends StatefulWidget {
  const EmojiTextFieldExample({super.key});

  @override
  State<EmojiTextFieldExample> createState() => _EmojiTextFieldExampleState();
}

class _EmojiTextFieldExampleState extends State<EmojiTextFieldExample> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final FocusNode _messageFocus = FocusNode();
  final FocusNode _commentFocus = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _commentController.dispose();
    _postController.dispose();
    _messageFocus.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Emoji Text Field Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_emotions,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Emoji Text Field',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Universal emoji picker for any TextField',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Example 1: Enhanced TextField
            _buildSection(
              title: '1. Enhanced TextField',
              description: 'TextField with built-in emoji button',
              child: EmojiTextField(
                controller: _messageController,
                focusNode: _messageFocus,
                hintText: 'Type a message with emojis...',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // Example 2: Multiline TextField
            _buildSection(
              title: '2. Multiline Support',
              description: 'Perfect for comments and posts',
              child: EmojiTextField(
                controller: _commentController,
                focusNode: _commentFocus,
                hintText: 'Write a comment...',
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // Example 3: Custom Configuration
            _buildSection(
              title: '3. Custom Configuration',
              description: 'Customized appearance and behavior',
              child: EmojiTextField(
                controller: _postController,
                hintText: 'Create a post...',
                maxLines: 3,
                emojiConfig: const EmojiViewConfig(
                  height: 350,
                  backgroundColor: Color(0xFFF8F9FA),
                  indicatorColor: Colors.purple,
                  categoryIconColor: Colors.purple,
                  columns: 8,
                  searchHintText: 'Find perfect emoji...',
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // Example 4: Manual Controls
            _buildSection(
              title: '4. Manual Controls',
              description: 'Programmatic emoji picker control',
              child: Column(
                children: [
                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Regular TextField',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            EmojiTextFieldView.showEmojiKeyboard(
                              context: context,
                              textController: _messageController,
                            );
                          },
                          icon: const Icon(Icons.emoji_emotions),
                          label: const Text('Bottom Sheet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            EmojiTextFieldView.showEmojiOverlay(
                              context: context,
                              textController: _messageController,
                              textFieldKey: GlobalKey(),
                            );
                          },
                          icon: const Icon(Icons.layers),
                          label: const Text('Overlay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Live Preview Section
            _buildSection(
              title: '5. Live Preview',
              description: 'See your text with emojis',
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _messageController.text.isEmpty
                          ? 'Type something above...'
                          : _messageController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: _messageController.text.isEmpty
                            ? Colors.grey[500]
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comment:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _commentController.text.isEmpty
                          ? 'Write a comment above...'
                          : _commentController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: _commentController.text.isEmpty
                            ? Colors.grey[500]
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Post:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _postController.text.isEmpty
                          ? 'Create a post above...'
                          : _postController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: _postController.text.isEmpty
                            ? Colors.grey[500]
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Features List
            _buildSection(
              title: '6. Key Features',
              description: 'What makes this plugin awesome',
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.integration_instructions,
                    title: 'Universal Compatibility',
                    description:
                        'Works with any TextField or TextEditingController',
                  ),
                  _buildFeatureItem(
                    icon: Icons.search,
                    title: 'Smart Search',
                    description:
                        'Find emojis by keywords like "happy", "love", "food"',
                  ),
                  _buildFeatureItem(
                    icon: Icons.access_time,
                    title: 'Recent Emojis',
                    description: 'Quick access to frequently used emojis',
                  ),
                  _buildFeatureItem(
                    icon: Icons.palette,
                    title: 'Fully Customizable',
                    description: 'Colors, sizes, categories, and behavior',
                  ),
                  _buildFeatureItem(
                    icon: Icons.vibration,
                    title: 'Haptic Feedback',
                    description:
                        'Enhanced user experience with tactile feedback',
                  ),
                  _buildFeatureItem(
                    icon: Icons.category,
                    title: 'Organized Categories',
                    description: 'Smileys, Animals, Food, Activities, and more',
                  ),
                ],
              ),
            ),

            // Footer
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Made with ❤️ for Flutter developers',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
