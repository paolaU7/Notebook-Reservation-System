import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/auth_provider.dart';
import '../../application/providers/notebook_list_provider.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/user.dart';
import '../widgets/device_card.dart';
import 'admin_screen.dart';

final _filterAvailableProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String?   _loginError;
  bool      _isLoading  = false;
  UserRole  _selectedRole = UserRole.student;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.trim().isEmpty) {
      setState(() => _loginError = 'Completá todos los campos');
      return;
    }
    setState(() { _isLoading = true; _loginError = null; });
    try {
      await ref.read(authProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _selectedRole,
          );
    } catch (e) {
      setState(() { _loginError = e.toString(); _isLoading = false; });
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // authProvider retorna AsyncValue<User?>
    final authAsync    = ref.watch(authProvider);
    final devicesAsync = ref.watch(notebookListProvider);

    // Mientras carga o hay error, mostrar login
    final user = authAsync.valueOrNull;

    if (user == null) return _buildLogin();

    if (user.role == UserRole.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: devicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text('Error: $e')),
              data:    (devices) => _buildGrid(devices, user),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ─── Fondo ──────────────────────────────────────────────────────────────

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF0A0F1C), Color(0xFF1A2A44)],
        ),
      ),
    );
  }

  // ─── Glass helper ────────────────────────────────────────────────────────

  Widget glass(Widget child, {EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  // ─── Login ───────────────────────────────────────────────────────────────

  Widget _buildLogin() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      body: Stack(
        children: [
          _background(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: glass(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'NRS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:      Colors.white,
                          fontSize:   28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Notebook Reservation System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:    Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller:   _emailCtrl,
                        style:        const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDeco('Email institucional', Icons.alternate_email),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller:  _passwordCtrl,
                        obscureText: true,
                        style:       const TextStyle(color: Colors.white),
                        decoration:  _inputDeco('DNI', Icons.badge_rounded),
                        onSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 14),
                      // Selector de rol
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final role in [UserRole.student, UserRole.teacher, UserRole.admin])
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(
                                  role == UserRole.student ? 'Alumno'
                                    : role == UserRole.teacher ? 'Docente'
                                    : 'Admin',
                                  style: TextStyle(
                                    color: _selectedRole == role
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: _selectedRole == role,
                                selectedColor: const Color(0xFF007AFF),
                                backgroundColor: Colors.white.withValues(alpha: 0.05),
                                onSelected: (_) =>
                                    setState(() => _selectedRole = role),
                              ),
                            ),
                        ],
                      ),
                      if (_loginError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _loginError!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Ingresar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText:  label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   const BorderSide(color: Color(0xFF00F2FF), width: 1.5),
      ),
      filled:    true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  // ─── Grid de dispositivos ─────────────────────────────────────────────────

  Widget _buildGrid(List<Device> devices, User user) {
    final onlyAvailable = ref.watch(_filterAvailableProvider);

    // Agrupar por especialidad
    final Map<String, List<Device>> groups = {};
    for (final d in devices) {
      if (user.role == UserRole.student && d.model == DeviceModel.tv) continue;
      if (onlyAvailable && d.status != DeviceStatus.available) continue;

      final key = d.model == DeviceModel.tv ? 'Televisores' : 'Notebooks';
      groups.putIfAbsent(key, () => []).add(d);
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Hola, ${user.email.split('@').first}',
                style: const TextStyle(
                  color:      Colors.white,
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Filtro disponibles
              Row(
                children: [
                  const Text('Solo libres',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Switch(
                    value:           onlyAvailable,
                    onChanged:       (v) => ref
                        .read(_filterAvailableProvider.notifier)
                        .state = v,
                    activeColor:     const Color(0xFF00F2FF),
                    inactiveThumbColor: Colors.white38,
                  ),
                ],
              ),
              // Logout
              IconButton(
                icon:    const Icon(Icons.logout_rounded, color: Colors.white54),
                onPressed: () =>
                    ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ),

        // Lista por especialidad
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: groups.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de especialidad
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 3, height: 16,
                          decoration: BoxDecoration(
                            color:        const Color(0xFF00F2FF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(
                            color:       Color(0xFF00F2FF),
                            fontSize:    11,
                            fontWeight:  FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap:  true,
                    physics:     const NeverScrollableScrollPhysics(),
                    itemCount:   entry.value.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:  2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                    ),
                    itemBuilder: (_, i) {
                      final d = entry.value[i];
                      return DeviceCard(
                        device:   d,
                        onCancel: d.status == DeviceStatus.inUse
                            ? () => ref
                                .read(notebookListProvider.notifier)
                                .cancelReservation(d.id)
                            : null,
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Bottom bar ───────────────────────────────────────────────────────────

  Widget _bottomBar() {
    return Positioned(
      bottom: 20,
      left:   20,
      right:  20,
      child: glass(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home_rounded,    color: Colors.white),
            Icon(Icons.history_rounded, color: Colors.white54),
            Icon(Icons.settings_rounded,color: Colors.white54),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}