import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers.dart';

class Homepage extends ConsumerWidget {
  final Function(int) onNavigate;

  const Homepage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // User profile bar
                if (user != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7C4DFF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF00D9FF).withOpacity(0.2),
                          backgroundImage: user.userMetadata?['avatar_url'] != null
                              ? NetworkImage(user.userMetadata!['avatar_url'])
                              : null,
                          child: user.userMetadata?['avatar_url'] == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF00D9FF),
                                  size: 28,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.userMetadata?['full_name'] ?? 
                                user.userMetadata?['name'] ?? 
                                'Usuario',
                                style: const TextStyle(
                                  color: Color(0xFFE8E8E8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A1A),
                                title: const Text('Cerrar sesión'),
                                content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFFF5252),
                                    ),
                                    child: const Text('Cerrar sesión'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await authService.signOut();
                            }
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFFF5252),
                          ),
                          tooltip: 'Cerrar sesión',
                        ),
                      ],
                    ),
                  ),
                // Hero section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          size: 64,
                          color: Color(0xFF00D9FF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'HandleCrash',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8E8E8),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF7C4DFF).withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          '✨ Asistente inteligente con IA',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7C4DFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Detecta daños vehiculares, chatea con IA sobre fotos, gestiona tu información y accede a recursos de emergencia.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[400],
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sección de acciones principales
                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8E8E8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tarjetas de acciones con diseño moderno
                _buildActionCard(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  title: 'Escanear Vehículo',
                  subtitle: 'Toma fotos y chatea con IA',
                  color: const Color(0xFF00D9FF),
                  onTap: () => onNavigate(1),
                ),
                const SizedBox(height: 12),
                
                _buildActionCard(
                  context: context,
                  icon: Icons.directions_car_filled_rounded,
                  title: 'Mis Vehículos',
                  subtitle: 'Gestiona tu información',
                  color: const Color(0xFF7C4DFF),
                  onTap: () => onNavigate(2),
                ),
                const SizedBox(height: 12),
                
                _buildActionCard(
                  context: context,
                  icon: Icons.phone_in_talk_rounded,
                  title: 'Emergencias',
                  subtitle: 'Números útiles en Colombia',
                  color: const Color(0xFFFF5252),
                  onTap: () => onNavigate(3),
                ),
                const SizedBox(height: 12),
                
                _buildActionCard(
                  context: context,
                  icon: Icons.link_rounded,
                  title: 'Recursos Externos',
                  subtitle: 'Guías y tutoriales',
                  color: const Color(0xFFFF6B9D),
                  onTap: () => onNavigate(4),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8E8E8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
