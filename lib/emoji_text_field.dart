import 'package:emoji_text_field/data/emoji_categories.dart';
import 'package:emoji_text_field/data/emoji_keywords.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_text_field/models/emoji_category.dart';

/// Universal Emoji Text Field that can work with any TextField
class EmojiTextFieldView {
  static void showEmojiKeyboard({
    required BuildContext context,
    required TextEditingController textController,
    EmojiViewConfig config = const EmojiViewConfig(),
    VoidCallback? onEmojiKeyboardClosed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EmojiKeyboardView(
          textController: textController,
          config: config,
          onEmojiKeyboardClosed: onEmojiKeyboardClosed,
        ),
      ),
    );
  }

  /// Show emoji picker as overlay
  static OverlayEntry? showEmojiOverlay({
    required BuildContext context,
    required TextEditingController textController,
    required GlobalKey textFieldKey,
    EmojiViewConfig config = const EmojiViewConfig(),
    VoidCallback? onEmojiOverlayClosed,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 10,
        right: 10,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          child: EmojiKeyboardView(
            textController: textController,
            config: config,
            onEmojiKeyboardClosed: () {
              overlayEntry.remove();
              onEmojiOverlayClosed?.call();
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    return overlayEntry;
  }
}

/// Configuration class for emoji keyboard
class EmojiViewConfig {
  final double height;
  final Color backgroundColor;
  final Color categoryIconColor;
  final Color indicatorColor;
  final TextStyle emojiTextStyle;
  final int columns;
  final bool showRecentTab;
  final int maxRecents;
  final bool enableSearch;
  final String searchHintText;
  final bool hapticFeedback;
  final Duration animationDuration;
  final Map<String, EmojiCategory>? customCategories;
  final Map<String, List<String>>? customKeywords;

  const EmojiViewConfig({
    this.height = 300,
    this.backgroundColor = const Color(0xFFF2F2F2),
    this.categoryIconColor = Colors.grey,
    this.indicatorColor = Colors.blue,
    this.emojiTextStyle = const TextStyle(fontSize: 24),
    this.columns = 7,
    this.showRecentTab = true,
    this.maxRecents = 28,
    this.enableSearch = true,
    this.searchHintText = 'Search emojis',
    this.hapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.customCategories,
    this.customKeywords,
  });
}

/// Main emoji keyboard view widget
class EmojiKeyboardView extends StatefulWidget {
  final TextEditingController textController;
  final EmojiViewConfig config;
  final VoidCallback? onEmojiKeyboardClosed;

  const EmojiKeyboardView({
    super.key,
    required this.textController,
    this.config = const EmojiViewConfig(),
    this.onEmojiKeyboardClosed,
  });

  @override
  State<EmojiKeyboardView> createState() => _EmojiKeyboardViewState();
}

class _EmojiKeyboardViewState extends State<EmojiKeyboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentEmojis = [];
  List<String> _searchResults = [];
  bool _isSearching = false;

  // Default emoji categories - can be overridden via config
  Map<String, EmojiCategory> get _categories =>
      widget.config.customCategories ?? _defaultCategories;

  static const Map<String, EmojiCategory> _defaultCategories = categoriesData;

  Map<String, List<String>> get _emojiKeywords =>
      widget.config.customKeywords ?? _defaultKeywords;

  static const Map<String, List<String>> _defaultKeywords = categoriesKeywords;

  @override
  void initState() {
    super.initState();
    int tabCount = widget.config.showRecentTab
        ? _categories.length
        : _categories.length - 1;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: widget.config.showRecentTab ? 1 : 0,
    );
    _searchController.addListener(_onSearchChanged);
    _loadRecentEmojis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecentEmojis() {
    // Default recent emojis - in real implementation, load from SharedPreferences
    _recentEmojis = [
      '😀',
      '😂',
      '😍',
      '🤔',
      '👍',
      '❤️',
      '🔥',
      '💯',
      '🎉',
      '🙏'
    ];
  }

  void _saveRecentEmojis() {
    // In real implementation, save to SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setStringList('recent_emojis', _recentEmojis);
    // });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _searchEmojis(query);
    });
  }

  List<String> _searchEmojis(String query) {
    final results = <String>[];

    // Search through emoji keywords
    _emojiKeywords.forEach((emoji, keywords) {
      if (keywords.any((keyword) => keyword.contains(query))) {
        results.add(emoji);
      }
    });

    // If no keyword matches, search through all emojis (fallback)
    if (results.isEmpty) {
      for (final category in _categories.values) {
        for (final emoji in category.emojis) {
          if (results.length < 50 && emoji.toLowerCase().contains(query)) {
            results.add(emoji);
          }
        }
      }
    }

    return results;
  }

  void _onEmojiSelected(String emoji) {
    // Insert emoji at cursor position
    final text = widget.textController.text;
    final selection = widget.textController.selection;
    final newText = (selection.start == -1 && selection.end == -1) ? emoji : text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );

    widget.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );

    // Add to recent emojis
    setState(() {
      _recentEmojis.remove(emoji);
      _recentEmojis.insert(0, emoji);
      if (_recentEmojis.length > widget.config.maxRecents) {
        _recentEmojis = _recentEmojis.take(widget.config.maxRecents).toList();
      }
    });

    _saveRecentEmojis();

    // Provide haptic feedback
    if (widget.config.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    final adjustedHeight = isKeyboardOpen && _isSearching
        ? widget.config.height - keyboardHeight + 100
        : widget.config.height;

    return AnimatedContainer(
      duration: widget.config.animationDuration,
      height: adjustedHeight.clamp(200, widget.config.height),
      decoration: BoxDecoration(
        color: widget.config.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Close button and title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emojis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onEmojiKeyboardClosed?.call();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search bar
          if (widget.config.enableSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.config.searchHintText,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
                // Auto focus search when keyboard is needed
                autofocus: false,
                onTap: () {
                  // Small delay to ensure keyboard height is calculated
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) setState(() {});
                  });
                },
              ),
            ),

          // Category tabs (hide when searching on small screens)
          if (!_isSearching || !isKeyboardOpen) ...[
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: widget.config.indicatorColor,
              indicatorWeight: 3,
              labelColor: widget.config.indicatorColor,
              unselectedLabelColor: widget.config.categoryIconColor,
              tabs: _getTabList(),
            ),
            const SizedBox(height: 8),
          ],

          // Content with flexible height
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildTabContent(),
          ),

          // Add bottom padding when keyboard is open
          if (isKeyboardOpen && _isSearching) const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Tab> _getTabList() {
    final tabs = <Tab>[];

    if (widget.config.showRecentTab) {
      tabs.add(const Tab(
        icon: Icon(Icons.access_time, size: 22),
        text: 'Recent',
      ));
    }

    _categories.forEach((key, category) {
      if (key != 'recent') {
        tabs.add(Tab(
          icon: Icon(category.icon, size: 22),
        ));
      }
    });

    return tabs;
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No emojis found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.config.columns,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildEmojiItem(_searchResults[index]);
      },
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: _getCategoryViews(),
    );
  }

  List<Widget> _getCategoryViews() {
    final views = <Widget>[];

    if (widget.config.showRecentTab) {
      views.add(_buildEmojiGrid(_recentEmojis));
    }

    _categories.forEach((key, category) {
      if (key != 'recent') {
        views.add(_buildEmojiGrid(category.emojis));
      }
    });

    return views;
  }

  Widget _buildEmojiGrid(List<String> emojis) {
    if (emojis.isEmpty) {
      return const Center(
        child: Text(
          'No emojis available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.config.columns,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        return _buildEmojiItem(emojis[index]);
      },
    );
  }

  Widget _buildEmojiItem(String emoji) {
    return InkWell(
      onTap: () => _onEmojiSelected(emoji),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            emoji,
            style: widget.config.emojiTextStyle,
          ),
        ),
      ),
    );
  }
}

/// Enhanced TextField widget that integrates with emoji picker
class EmojiTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;
  final InputDecoration? decoration;
  final EmojiViewConfig emojiConfig;
  final bool showEmojiButton;
  final VoidCallback? onEmojiKeyboardToggle;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool enabled;

  const EmojiTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.decoration,
    this.emojiConfig = const EmojiViewConfig(),
    this.showEmojiButton = true,
    this.onEmojiKeyboardToggle,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  State<EmojiTextField> createState() => _EmojiTextFieldState();
}

class _EmojiTextFieldState extends State<EmojiTextField> {
  bool _showEmojiKeyboard = false;

  void _toggleEmojiKeyboard() {
    setState(() {
      _showEmojiKeyboard = !_showEmojiKeyboard;
    });

    if (_showEmojiKeyboard) {
      FocusScope.of(context).unfocus();
      EmojiTextFieldView.showEmojiKeyboard(
        context: context,
        textController: widget.controller,
        config: widget.emojiConfig,
        onEmojiKeyboardClosed: () {
          setState(() {
            _showEmojiKeyboard = false;
          });
        },
      );
    }

    widget.onEmojiKeyboardToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: widget.decoration?.copyWith(
            hintText: widget.hintText,
            suffixIcon: widget.showEmojiButton
                ? IconButton(
                    onPressed: _toggleEmojiKeyboard,
                    icon: Icon(
                      _showEmojiKeyboard
                          ? Icons.keyboard
                          : Icons.emoji_emotions,
                      color: _showEmojiKeyboard ? Colors.blue : Colors.grey,
                    ),
                  )
                : widget.decoration?.suffixIcon,
          ) ??
          InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.showEmojiButton
                ? IconButton(
                    onPressed: _toggleEmojiKeyboard,
                    icon: Icon(
                      _showEmojiKeyboard
                          ? Icons.keyboard
                          : Icons.emoji_emotions,
                      color: _showEmojiKeyboard ? Colors.blue : Colors.grey,
                    ),
                  )
                : null,
          ),
      onTap: () {
        if (_showEmojiKeyboard) {
          setState(() {
            _showEmojiKeyboard = false;
          });
        }
      },
    );
  }
}
