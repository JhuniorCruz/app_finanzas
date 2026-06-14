import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_finanzas/core/theme/app_theme.dart';

import '../controller/advisor_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_prompts.dart';

class AdvisorPage extends StatefulWidget {
  const AdvisorPage({super.key});

  @override
  State<AdvisorPage> createState() => _AdvisorPageState();
}

class _AdvisorPageState extends State<AdvisorPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvisorController>().initChat();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    context.read<AdvisorController>().sendMessage(text).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo claro
      appBar: AppBar(
        title: const Text('Asesor IA'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
          color: Color.fromRGBO(48, 50, 191, 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            tooltip: 'Reiniciar chat',
            onPressed: () {
              context.read<AdvisorController>().resetChat();
            },
          )
        ],
      ),
      body: Consumer<AdvisorController>(
        builder: (context, controller, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: _Header(),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    return ChatBubble(
                      text: msg.text,
                      isUser: msg.isUser,
                    );
                  },
                ),
              ),
              if (controller.isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TypingIndicator(),
                  ),
                ),
              const SizedBox(height: 8),
              QuickPrompts(onPromptSelected: _sendMessage),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Pregunta sobre tus finanzas...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 24,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
                          onPressed: () => _sendMessage(_textController.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C6BF6), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18.0,
            offset: Offset(0.0, 8.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asesor Inteligente',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 6.0),
          Text('¿En qué te puedo ayudar hoy?', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Analizando',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final value = (_controller.value - delay) % 1.0;
                  final opacity = value < 0 ? 0.0 : (value < 0.5 ? value * 2 : (1 - value) * 2);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6BF6).withOpacity(opacity.clamp(0.2, 1.0)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
