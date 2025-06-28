import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart';
import 'package:money_mind_mobile/features/auth/screens/login_screen.dart';
import 'package:money_mind_mobile/features/incomes/screens/add_income_screen.dart';
import 'package:money_mind_mobile/features/expenses/screens/add_expense_screen.dart';
import 'package:money_mind_mobile/features/budgets/screens/add_budget_screen.dart';
import 'package:money_mind_mobile/features/categories/screens/add_category_screen.dart';
import 'package:money_mind_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:money_mind_mobile/features/recomendaciones/providers/recomendacion_provider.dart';
import 'package:money_mind_mobile/features/history/screens/history_screen.dart';
import 'package:money_mind_mobile/features/history/providers/history_provider.dart';

import 'package:money_mind_mobile/domain/repositories/notification_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _notificationSubscription;
  bool _isNotificationDialogShowing = false;
  final List<Map<String, dynamic>> _notificationQueue = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeSignalR();
    });
  }

  Future<void> _initializeSignalR() async {
    try {
      final notificationRepository = Provider.of<NotificationRepository>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        await notificationRepository.connect();
        await notificationRepository.joinGroup(userId.toString());

        _notificationSubscription = notificationRepository.notificationStream.listen(
          (notificationData) {
            _handleNotification(notificationData);
          },
          onError: (error) {
            log('Error en stream de notificaciones: $error');
          },
        );
      } else {
        log('No hay usuario autenticado.');
      }
    } catch (e) {
      log('Error al inicializar SignalR: $e');
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    if (_isNotificationDialogShowing) {
      _notificationQueue.add(data);
    } else {
      _showNotificationDialog(data);
    }
  }

  void _showNotificationDialog(Map<String, dynamic> notificationData) {
    final type = notificationData['type'] ?? notificationData['Type'];
    final message = notificationData['mensaje'] ?? notificationData['Mensaje'] ?? 'Has excedido el 90% de tu presupuesto.';

    String title = 'Notificación';
    Color backgroundColor = Colors.blue.shade50;
    IconData icon = Icons.info;
    Color iconColor = Colors.blue;

    switch (type) {
      case 'BudgetWarning':
        title = '¡Alerta de Presupuesto!';
        backgroundColor = Colors.orange.shade50;
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'BudgetExceeded':
        title = '¡Presupuesto Excedido!';
        backgroundColor = Colors.red.shade50;
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      default:
        title = 'Nueva Notificación';
        backgroundColor = Colors.grey.shade100;
        icon = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    setState(() {
      _isNotificationDialogShowing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: backgroundColor,
              title: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
                    ),
                  ),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    final currentRouteName = ModalRoute.of(context)?.settings.name;
                    if (currentRouteName != '/home') {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          );
        },
      ).then((_) {
        if (mounted) {
          setState(() {
            _isNotificationDialogShowing = false;
          });
          if (_notificationQueue.isNotEmpty) {
            final next = _notificationQueue.removeAt(0);
            _showNotificationDialog(next);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    try {
      final notificationRepository = Provider.of<NotificationRepository>(context, listen: false);
      notificationRepository.disconnect();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: const RouteSettings(name: '/login'),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final recomendacionProvider = Provider.of<RecomendacionProvider>(context, listen: false);
      if (user != null &&
          recomendacionProvider.recomendaciones.isEmpty &&
          !recomendacionProvider.isLoading) {
        recomendacionProvider.loadRecomendaciones(user.id);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyMind 💰'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de Gastos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => HistoryProvider(),
                    child: HistoryScreen(usuarioId: user?.id ?? 0),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              color: colorScheme.primaryContainer,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, size: 48, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '¡Bienvenido, ${user?.nombre ?? "Usuario"}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildMenuButton(context, icon: Icons.attach_money, label: 'Registrar Ingreso', color: Colors.green.shade600, screen: const AddIncomeScreen()),
            const SizedBox(height: 16),
            _buildMenuButton(context, icon: Icons.money_off, label: 'Registrar Gasto', color: Colors.red.shade400, screen: const AddExpenseScreen()),
            const SizedBox(height: 16),
            _buildMenuButton(context, icon: Icons.account_balance_wallet, label: 'Nuevo Presupuesto', color: Colors.blue.shade500, screen: const AddBudgetScreen()),
            const SizedBox(height: 16),
            _buildMenuButton(context, icon: Icons.bar_chart, label: 'Resumen Financiero', screen: DashboardScreen(usuarioId: user?.id ?? 0), color: Colors.teal.shade600),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recomendaciones Ecológicas 🍃', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Consumer<RecomendacionProvider>(
                          builder: (context, provider, _) {
                            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                            if (provider.recomendaciones.isEmpty) return const Center(child: Text('No hay recomendaciones ecológicas disponibles.'));
                            return ListView.builder(
                              itemCount: provider.recomendaciones.length,
                              itemBuilder: (_, index) {
                                final r = provider.recomendaciones[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.green.shade50,
                                  child: ListTile(
                                    leading: const Icon(Icons.eco, color: Colors.green),
                                    title: Text(r.titulo),
                                    subtitle: Text(r.descripcion),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String label, required Color color, required Widget screen}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
              settings: RouteSettings(name: label == 'Registrar Gasto' ? '/addExpense' : '/home'),
            ),
          );
        },
      ),
    );
  }
}
