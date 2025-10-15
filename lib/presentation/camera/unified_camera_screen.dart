import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/vehicle.dart';
import '../providers.dart';

// Provider para cargar vehículos
final vehiclesListProvider = FutureProvider<List<Vehicle>>((ref) async {
  final getAllVehiclesUseCase = ref.watch(getAllVehiclesUseCaseProvider);
  return await getAllVehiclesUseCase.execute();
});

class UnifiedCameraScreen extends ConsumerStatefulWidget {
  final CameraDescription camera;

  const UnifiedCameraScreen({super.key, required this.camera});

  @override
  ConsumerState<UnifiedCameraScreen> createState() => _UnifiedCameraScreenState();
}

class _UnifiedCameraScreenState extends ConsumerState<UnifiedCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  
  // Chat state
  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  Uint8List? _imageBytes;
  
  // Vehicle selection state
  Vehicle? _selectedVehicle;
  
  // Panel state
  double _panelHeight = 0.0; // 0 = hidden, 0.4 = partial, 0.8 = full
  bool _chatVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final bytes = await File(image.path).readAsBytes();
      
      setState(() {
        _imageBytes = bytes;
        _chatVisible = true;
        _panelHeight = 0.4;
        _messages.clear();
        _messages.add(
          _ChatMessage(
            role: ChatRole.system,
            text: _selectedVehicle != null 
                ? 'Foto capturada. Vehículo seleccionado: ${_selectedVehicle!.make} ${_selectedVehicle!.model}. Pregunta sobre los daños o el estado del vehículo.'
                : 'Foto capturada. Puedes preguntar sobre daños, reparaciones o cualquier detalle de la imagen.',
          ),
        );
      });
      
      // Auto-scroll to show chat
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    
    if (_sending || _imageBytes == null) return;

    // Validate Gemini API key
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    if (geminiKey == null || geminiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configura GEMINI_API_KEY en tu .env para usar el chat.'),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    // Build user prompt with vehicle context
    String userPrompt = text.isEmpty ? 'Analiza la imagen y describe lo que ves.' : text;
    
    if (_selectedVehicle != null) {
      final vehicleInfo = _buildVehicleContext(_selectedVehicle!);
      userPrompt = '$vehicleInfo\n\n$userPrompt';
    }

    final userMsg = _ChatMessage(
      role: ChatRole.user, 
      text: text.isEmpty ? 'Analiza la imagen' : text,
    );
    setState(() {
      _messages.add(userMsg);
      _textController.clear();
    });

    // Auto-scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      Gemini gemini;
      try {
        gemini = Gemini.instance;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini no está inicializado.')),
        );
        setState(() {
          _messages.add(_ChatMessage(
            role: ChatRole.model, 
            text: 'Error: Gemini no está inicializado.',
          ));
          _sending = false;
        });
        return;
      }

      // Build chat contents with image
      final contents = <Content>[
        ..._toContents(_messages.where((m) => m.role != ChatRole.system).toList()),
        Content(
          role: 'user',
          parts: [
            Part.text(userPrompt),
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
      
      setState(() {
        _messages.add(_ChatMessage(
          role: ChatRole.model,
          text: output ?? 'No obtuve respuesta.',
        ));
      });
      
      // Auto-scroll
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: ChatRole.model,
          text: 'Error: $e',
        ));
      });
    } finally {
      setState(() => _sending = false);
    }
  }

  String _buildVehicleContext(Vehicle vehicle) {
    return '''INFORMACIÓN DEL VEHÍCULO:
- Marca: ${vehicle.make}
- Modelo: ${vehicle.model}
- Año: ${vehicle.year}
- Color: ${vehicle.color}
- Placa: ${vehicle.licensePlate}
- VIN: ${vehicle.vin}
- Propietario: ${vehicle.ownerName}
${vehicle.insuranceCompany != null ? '- Aseguradora: ${vehicle.insuranceCompany}' : ''}
${vehicle.insurancePolicy != null ? '- Póliza: ${vehicle.insurancePolicy}' : ''}''';
  }

  List<Content> _toContents(List<_ChatMessage> msgs) {
    final contents = <Content>[];
    for (final m in msgs) {
      if (m.role == ChatRole.system) continue;
      contents.add(
        Content(
          role: m.role == ChatRole.user ? 'user' : 'model',
          parts: [Part.text(m.text)],
        ),
      );
    }
    return contents;
  }

  void _togglePanelHeight() {
    setState(() {
      if (_panelHeight == 0.4) {
        _panelHeight = 0.8;
      } else {
        _panelHeight = 0.4;
      }
    });
  }

  void _closeChat() {
    setState(() {
      _chatVisible = false;
      _panelHeight = 0.0;
      _imageBytes = null;
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final canSend = !_sending && _imageBytes != null;

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: CameraPreview(_controller),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00D9FF),
                  ),
                );
              }
            },
          ),
          
          // Top bar with vehicle selector
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Color(0xFF00D9FF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final vehiclesAsync = ref.watch(vehiclesListProvider);
                        
                        return vehiclesAsync.when(
                          data: (vehicles) {
                            if (vehicles.isEmpty) {
                              return const Text(
                                'No hay vehículos guardados',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              );
                            }
                            
                            return DropdownButton<Vehicle?>(
                              value: _selectedVehicle,
                              isExpanded: true,
                              hint: const Text(
                                'Seleccionar vehículo',
                                style: TextStyle(color: Colors.white70),
                              ),
                              dropdownColor: const Color(0xFF1A1A1A),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Color(0xFF00D9FF),
                              ),
                              items: [
                                const DropdownMenuItem<Vehicle?>(
                                  value: null,
                                  child: Text(
                                    'Ninguno',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                ...vehicles.map((vehicle) {
                                  return DropdownMenuItem<Vehicle?>(
                                    value: vehicle,
                                    child: Text(
                                      '${vehicle.make} ${vehicle.model} (${vehicle.licensePlate})',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedVehicle = value);
                              },
                            );
                          },
                          loading: () => const Text(
                            'Cargando vehículos...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          error: (error, stack) => Text(
                            'Error al cargar vehículos',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat panel (slides up from bottom)
          if (_chatVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: screenHeight * _panelHeight,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    final delta = -details.delta.dy / screenHeight;
                    _panelHeight = (_panelHeight + delta).clamp(0.0, 0.8);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      GestureDetector(
                        onTap: _togglePanelHeight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A3A),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00D9FF).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome_rounded,
                                            color: Color(0xFF00D9FF),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Chat con IA',
                                          style: TextStyle(
                                            color: Color(0xFFE8E8E8),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _closeChat,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFF3A3A3A)),
                      
                      // Captured image preview (small)
                      if (_imageBytes != null)
                        Container(
                          height: 100,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00D9FF).withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      
                      // Messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isUser = msg.role == ChatRole.user;
                            final isSystem = msg.role == ChatRole.system;
                            
                            if (isSystem) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        msg.text,
                                        style: const TextStyle(
                                          color: Color(0xFF7C4DFF),
                                          fontSize: 12,
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
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF00D9FF)
                                      : const Color(0xFF242424),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: isUser ? const Radius.circular(14) : const Radius.circular(4),
                                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(14),
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
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Input area
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFF3A3A3A),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF242424),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF3A3A3A),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _textController,
                                    decoration: const InputDecoration(
                                      hintText: 'Pregunta sobre el vehículo...',
                                      hintStyle: TextStyle(color: Color(0xFF6B6B6B)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    minLines: 1,
                                    maxLines: 3,
                                    style: const TextStyle(color: Color(0xFFE8E8E8)),
                                    onSubmitted: (_) => canSend ? _send() : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: canSend ? const Color(0xFF00D9FF) : const Color(0xFF3A3A3A),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: canSend ? _send : null,
                                  icon: _sending
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                          ),
                                        )
                                      : Icon(
                                          Icons.send_rounded,
                                          color: canSend ? Colors.black : const Color(0xFF6B6B6B),
                                          size: 20,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_chatVisible
          ? FloatingActionButton.extended(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text(
                'Tomar Foto',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

enum ChatRole { user, model, system }

class _ChatMessage {
  final ChatRole role;
  final String text;

  _ChatMessage({required this.role, required this.text});
}
