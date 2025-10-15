import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class CameraChatPage extends StatefulWidget {
  final File imageFile;

  const CameraChatPage({super.key, required this.imageFile});

  @override
  State<CameraChatPage> createState() => _CameraChatPageState();
}

class _CameraChatPageState extends State<CameraChatPage> {
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageFile.readAsBytesSync();
    // Add system prompt/info message
    _messages.add(
      _ChatMessage(
        role: ChatRole.system,
        text: 'Puedes hacer preguntas sobre la imagen capturada. Por ejemplo: "¿Qué ves en esta foto?" o "Descríbeme los daños del coche".',
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    
    // Early validations
    if (_sending || _imageBytes == null) return;

    setState(() => _sending = true);

    // Push user's message (can be empty meaning "analyze the image")
    final userText = text.isEmpty ? 'Analiza la imagen y describe lo que ves.' : text;
    final userMsg = _ChatMessage(role: ChatRole.user, text: userText);
    setState(() {
      _messages.add(userMsg);
      _textController.clear();
    });

    try {
      // Verify Gemini is initialized
      Gemini gemini;
      try {
        gemini = Gemini.instance;
      } catch (e) {
        // Catch LateInitializationError or any initialization error
        if (e.toString().contains('LateInitializationError') || 
            e.toString().contains('has not been initialized')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gemini no está inicializado. Revisa tu GEMINI_API_KEY en .env.')),
          );
          setState(() {
            _messages.add(_ChatMessage(role: ChatRole.model, text: 'Error: Gemini no está inicializado.'));
            _sending = false;
          });
          return;
        }
        rethrow; // Re-throw if it's a different error
      }

      // Build chat contents including the image as inline bytes in the same user turn
      final contents = <Content>[
        // Prior messages: keep the conversation by translating _messages to Contents
        ..._toContents(_messages.where((m) => m.role != ChatRole.system).toList(), includeImageForLastUser: false),
        // Current user message with image attached so model can reference it on each new question
        Content(
          role: 'user',
          parts: [
            Part.text(userText),
            if (_imageBytes != null)
              Part.inline(
                InlineData(
                  mimeType: 'image/jpeg',
                  data: base64Encode(_imageBytes!),
                ),
              ),
          ],
        ),
      ];

      final response = await gemini.chat(contents);

      final output = response?.output?.trim();
      if (output != null && output.isNotEmpty) {
        setState(() {
          _messages.add(_ChatMessage(role: ChatRole.model, text: output));
        });
      } else {
        setState(() {
          _messages.add(_ChatMessage(role: ChatRole.model, text: 'No obtuve respuesta.'));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(role: ChatRole.model, text: 'Ocurrió un error: $e'));
      });
    } finally {
      setState(() => _sending = false);
    }
  }

  List<Content> _toContents(List<_ChatMessage> msgs, {bool includeImageForLastUser = false}) {
    final contents = <Content>[];
    for (int i = 0; i < msgs.length; i++) {
      final m = msgs[i];
      if (m.role == ChatRole.system) continue; // system not sent
      final isLast = i == msgs.length - 1;
      contents.add(
        Content(
          role: m.role == ChatRole.user ? 'user' : 'model',
          parts: [
            Part.text(m.text),
            if (includeImageForLastUser && isLast && m.role == ChatRole.user && _imageBytes != null)
              Part.inline(
                InlineData(
                  mimeType: 'image/jpeg',
                  data: base64Encode(_imageBytes!),
                ),
              ),
          ],
        ),
      );
    }
    return contents;
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !_sending && _imageBytes != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat sobre la foto'),
      ),
      body: Column(
        children: [
          // Image preview
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _imageBytes == null
                ? const Center(child: Text('Sin imagen'))
                : Image.memory(_imageBytes!, fit: BoxFit.cover),
          ),
          const Divider(height: 1),
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == ChatRole.user;
                final isSystem = msg.role == ChatRole.system;
                
                if (isSystem) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF7C4DFF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF7C4DFF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            msg.text,
                            style: const TextStyle(
                              color: Color(0xFF7C4DFF),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF00D9FF)
                          : const Color(0xFF242424),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: const Color(0xFF3A3A3A),
                              width: 1,
                            ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.black : const Color(0xFFE8E8E8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF3A3A3A),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF3A3A3A),
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Pregunta sobre la imagen...',
                          hintStyle: TextStyle(color: Color(0xFF6B6B6B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: Color(0xFFE8E8E8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: canSend ? const Color(0xFF00D9FF) : const Color(0xFF3A3A3A),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: canSend ? _send : null,
                      icon: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: canSend ? Colors.black : const Color(0xFF6B6B6B),
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum ChatRole { user, model, system }

class _ChatMessage {
  final ChatRole role;
  final String text;

  _ChatMessage({required this.role, required this.text});
}
