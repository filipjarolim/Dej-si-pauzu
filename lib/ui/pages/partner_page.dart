import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/groq_service.dart';
import '../../core/services/navbar_service.dart';
import '../../core/services/chat_history_service.dart';
import '../foundations/colors.dart';
import '../widgets/chat_components.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _animController;
  late AnimationController _reactionController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _jumpAnimation;
  
  // Chat State
  final GroqService _groqService = GroqService(dotenv.env['GROQ_API_KEY'] ?? '');
  final ChatHistoryService _historyService = ChatHistoryService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<({String text, bool isUser})> _messages = [];

  bool _isLoading = false;
  bool _hasStartedChat = false;
  int _currentGenerationId = 0; // To track active generation for cancellation

  @override
  void initState() {
    super.initState();
    
    // Idle Animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutQuad),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutQuad),
    );

    // Reaction Animation (Happy Jump)
    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 5.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 30),
    ]).animate(_reactionController);
    
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadMessages();
    if (history.isNotEmpty && mounted) {
       setState(() {
         _messages.addAll(history);
         _hasStartedChat = true;
       });
       // If we have history, maybe we don't auto-hide navbar immediately until user interacts? 
       // Or we can just let them read. Let's start with navbar shown.
       WidgetsBinding.instance.addPostFrameCallback((_) {
         // Scroll to bottom after loading
         if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
         }
       });
    }
  }

  @override
  void dispose() {
    NavbarService.instance.show(); // Ensure navbar is shown when leaving
    _animController.dispose();
    _reactionController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startChat() {
    NavbarService.instance.hide(); // Hide navbar when chat starts
    setState(() {
      _hasStartedChat = true;
    });
  }



  void _endChat() {
    FocusScope.of(context).unfocus();
    NavbarService.instance.show(); // Show navbar
    setState(() {
      _hasStartedChat = false;
      _isLoading = false;
      _currentGenerationId++; // Cancel any pending
      // We don't clear messages so history remains, but user sees Welcome screen
      // If they click Start, history is still there. 
      // If we want to "reset" visually, we might need to scroll up or something, 
      // but showing Welcome screen covers it. 
      // Actually, if we just toggle _hasStartedChat, the AnimatedSwitcher will switch back to _buildCallToAction.
    });
  }

  Future<void> _sendMessage([String? textOverride]) async {
    final text = textOverride ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (textOverride == null) {
      _textController.clear();
    }
    
    setState(() {
      _hasStartedChat = true; 
      _messages.add((text: text, isUser: true));
      _isLoading = true;
      _currentGenerationId++; // Start new generation scope
    });
    
    // Animate insertion
    _listKey.currentState?.insertItem(_messages.length - 1);
    _scrollToBottom();
    
    // Trigger Character Reaction
    _reactionController.forward(from: 0.0);
    
    // Ensure immersive mode
    NavbarService.instance.hide();

    try {
      HapticFeedback.selectionClick();
      // SystemSound.play(SystemSoundType.click); // Subtle sound

      final int myGenerationId = _currentGenerationId;
      
      final response = await _groqService.sendMessage(text);
      
      // Check if cancelled
      if (mounted && _currentGenerationId == myGenerationId) {
        setState(() {
          _messages.add((text: response, isUser: false));
          _isLoading = false;
        });

        _listKey.currentState?.insertItem(_messages.length - 1);
        HapticFeedback.lightImpact(); // Success haptic
        // Play success sound if available
        
        // Save History
        _historyService.saveMessages(_messages);
        
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted && _currentGenerationId == _currentGenerationId) { // Check ID also here
        setState(() {
          _messages.add((text: 'Omlouvám se, něco se pokazilo: $e', isUser: false));
          _isLoading = false;
        });
        _listKey.currentState?.insertItem(_messages.length - 1);
        _scrollToBottom();
      }
    }
  }

  void _stopGeneration() {
    if (!_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = false;
      _currentGenerationId++; // Invalidate current generation
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final TextTheme text = Theme.of(context).textTheme;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, // Handle layout manually
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            'assets/images/sceneaichat.jpeg',
            fit: BoxFit.cover,
          ),

          // 2. Gradient Overlay - UPDATED: Removed heavy dark overlay
          // Replaced with a very subtle tint to ensure text readability without gloom
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); 
                NavbarService.instance.toggle(); 
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.1), // Very subtle light bleed
                      Colors.white.withOpacity(0.2),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Main Content Layer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: SafeArea(
              bottom: false, 
              child: Column(
                children: [
                  // --- TOP SECTION: Character & Welcome ---
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _hasStartedChat || isKeyboardOpen 
                        ? size.height * 0.35 
                        : size.height * 0.55, 
                    constraints: const BoxConstraints(minHeight: 200),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: Listenable.merge([_animController, _reactionController]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value + _jumpAnimation.value),
                              child: Transform.scale(
                                scale: _breatheAnimation.value + (_jumpAnimation.value < 0 ? 0.05 : 0),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    _reactionController.forward(from: 0.0);
                                  },
                                  child: Image.asset(
                                    'assets/images/charmeditating.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // --- MIDDLE SECTION: Chat / Welcome ---
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1), 
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _hasStartedChat
                          ? _buildChatList()
                          : _buildCallToAction(text),
                    ),
                  ),

                  // --- BOTTOM SECTION: Input ---
                  if (_hasStartedChat) 
                    _buildInputArea()
                  else 
                     const SizedBox(height: 120), 
                ],
              ),
            ),
          ),

          // 4. Close / Menu Button Overlay
          if (_hasStartedChat && !isKeyboardOpen)
             Positioned(
               top: MediaQuery.of(context).padding.top + 8,
               right: 16,
               child: _buildCloseButton(),
             ),
        ],
      ),
    );
  }

  Widget _buildCallToAction(TextTheme text) {
    final hour = DateTime.now().hour;
    String greeting = 'Ahoj, Filipe!';
    if (hour < 12) greeting = 'Dobré ráno, Filipe!';
    else if (hour < 18) greeting = 'Dobré odpoledne, Filipe!';
    else greeting = 'Dobrý večer, Filipe!';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(), 
                    // Frosted White Card for Greeting
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85), // High opacity for "Card" feel
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2C3E50).withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                greeting,
                                style: text.headlineMedium?.copyWith(
                                  color: const Color(0xFF1E293B), // Slate 800 - Very high contrast
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Jak se dnes cítíš? Vyber si téma\nnebo začni psát cokoliv.',
                                textAlign: TextAlign.center,
                                style: text.bodyLarge?.copyWith(
                                  color: const Color(0xFF475569), // Slate 600
                                  height: 1.5,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Quick Intent Chips
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildQuickChip('😰 Cítím stres', 'Ahoj, cítím se dnes ve stresu a potřebuji uklidnit.', const Color(0xFFFF6B6B)), 
                                  _buildQuickChip('😴 Nemohu spát', 'Nemohu usnout, máš nějakou radu?', const Color(0xFF4ECDC4)), 
                                  _buildQuickChip('😤 Jsem naštvaný', 'Něco mě naštvalo a potřebuji to ventilovat.', const Color(0xFFFFD93D)), 
                                  _buildQuickChip('🧘 Chci meditovat', 'Chtěl bych si dát krátkou meditaci.', const Color(0xFFA06CD5)), 
                                  _buildQuickChip('👋 Jen tak pokecat', 'Ahoj, jak se máš?', const Color(0xFF6C5CE7)), 
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickChip(String label, String prompt, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startChatWithPrompt(prompt),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white, // Solid white background for pop
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5), // Colored border
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2), // Colored shadow
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF2D3436), // Dark text inside chip
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _startChatWithPrompt(String prompt) {
    _startChat();
    _sendMessage(prompt);
  }

  Widget _buildChatList() {
    return AnimatedList(
      key: _listKey,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      initialItemCount: _messages.length,
      itemBuilder: (context, index, animation) {
        final message = _messages[index];
        return ChatBubble(
          text: message.text,
          isUser: message.isUser,
          animation: animation,
          onLongPress: () => _showMessageActions(context, index),
        );
      },
    );
  }

  void _showMessageActions(BuildContext context, int index) {
    final message = _messages[index];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Copy
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.white),
              title: const Text('Kopírovat', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zpráva zkopírována'), duration: Duration(seconds: 1)),
                );
              },
            ),
            // Delete
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.coral),
              title: const Text('Smazat', style: TextStyle(color: AppColors.coral)),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(index);
              },
            ),
            // Regenerate (Only if it's the last AI message)
            if (!message.isUser && index == _messages.length - 1)
               ListTile(
                leading: const Icon(Icons.refresh_rounded, color: AppColors.skyBlue),
                title: const Text('Zkusit znovu', style: TextStyle(color: AppColors.skyBlue)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(index); // Remove the bad response
                  // Find last user message
                  if (index > 0) {
                     final lastUserMsg = _messages[index - 1]; // Assuming alternating, but better safe
                     // Actually, just find the last user message
                     _regenerateLastUserMessage();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _deleteMessage(int index) {
    final removed = _messages.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: ChatBubble(text: removed.text, isUser: removed.isUser, animation: animation),
        ),
      ),
    );
     _historyService.saveMessages(_messages);
  }

  Future<void> _regenerateLastUserMessage() async {
    if (_messages.isEmpty) return;
    
    // Find last user message
    int lastUserIndex = _messages.lastIndexWhere((m) => m.isUser);
    if (lastUserIndex != -1) {
       final lastMsg = _messages[lastUserIndex];
       setState(() => _isLoading = true);
        try {
           final response = await _groqService.sendMessage(lastMsg.text);
           if (mounted) {
              setState(() {
                _messages.add((text: response, isUser: false));
                _isLoading = false;
              });
              _listKey.currentState?.insertItem(_messages.length - 1);
              HapticFeedback.lightImpact();
              _historyService.saveMessages(_messages);
              _scrollToBottom();
           }
        } catch (e) {
             if (mounted) {
              setState(() {
                _messages.add((text: 'Chyba: $e', isUser: false));
                _isLoading = false;
              });
              _listKey.currentState?.insertItem(_messages.length - 1);
            }
        }
    }
  }

  void _showHistoryActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text(
              'Osobnost Parťáka',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color:Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Persona Selector
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                   _buildPersonaCard('zen', 'Zen Mistr', '🧘', const Color(0xFF4CA1AF)),
                   const SizedBox(width: 12),
                   _buildPersonaCard('friend', 'Kamarád', '🤝', const Color(0xFF6C5CE7)),
                   const SizedBox(width: 12),
                   _buildPersonaCard('coach', 'Kouč', '🔥', const Color(0xFFFF6B6B)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 32),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever_rounded, color: AppColors.coral),
              title: const Text('Vymazat historii', style: TextStyle(color: AppColors.coral)),
              onTap: () {
                Navigator.pop(context);
                _showClearConfirmation();
              },
            ),
             ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restart_alt_rounded, color: AppColors.skyBlue),
              title: const Text('Nové téma', style: TextStyle(color: AppColors.skyBlue)),
              onTap: () {
                Navigator.pop(context);
                _groqService.clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parťák zapomněl předchozí kontext.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  String _selectedPersona = 'zen';

  Widget _buildPersonaCard(String key, String title, String emoji, Color color) {
    final bool isSelected = _selectedPersona == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPersona = key;
        });
        _groqService.setPersona(key);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Přepnuto na: $title $emoji')
          )
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Opravdu smazat?', style: TextStyle(color: Colors.white)),
        content: const Text('Tato akce je nevratná.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _hasStartedChat = false; 
                // Return to welcome screen if empty
              });
              _historyService.clearHistory();
              _groqService.clearHistory();
            },
            child: const Text('Smazat', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // History/Menu Button
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showHistoryActions();
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Close Button
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _endChat();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    // Dynamic bottom padding:
    // When keyboard is open: minimal padding (12)
    // When closed: Navbar height (~80) + Safe Area Bottom + buffer
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    const double navBarHeight = 80.0; 
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // Reduced bottom padding to bring input closer to navbar
    final double bottomPadding = keyboardHeight > 0 
        ? 12.0 
        : (navBarHeight + safeAreaBottom - 8.0); // Subtracted to reduce visual gap

    return ValueListenableBuilder<bool>(
      valueListenable: NavbarService.instance.isVisible,
      builder: (context, isNavbarVisible, child) {
        final double bottomPadding = keyboardHeight > 0 
            ? 12.0 
            : (isNavbarVisible ? (navBarHeight + safeAreaBottom - 8.0) : (safeAreaBottom + 12.0));

        return Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPadding),
          // child is passed from builder
          child: child,
        );
      },
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Solid White Pill
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  // Roboto ensures full Latin Extended support for Czech diacritics
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF2C3E50), 
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ), 
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 4,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration( // Removed hints to be cleaner or keep simple
                    hintText: 'Napiš zprávu...',
                    hintStyle: const TextStyle(color: Color(0xFF90A4AE)), // Slate Grey Hint
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    isDense: true,
                    // Voice Input Icon
                    suffixIcon: IconButton(
                       icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary),
                       onPressed: () {
                          // Placeholder for Voice Input
                          ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Hlasové zadávání bude brzy dostupné! 🎤'))
                          );
                       },
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Floating Send Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.small(
                onPressed: _isLoading ? null : () => _sendMessage(),
                backgroundColor: _isLoading ? Colors.grey.withOpacity(0.3) : AppColors.primary, // Use Brand Color
                elevation: 4, // Add shadow
                child: _isLoading 
                    ? InkWell(
                        onTap: _stopGeneration,
                        child: const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: Icon(Icons.stop_rounded, color: Colors.white, size: 20)
                        ),
                      )
                    : const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
          ],
        ),
    );
  }
}
