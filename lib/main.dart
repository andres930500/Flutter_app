// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// 🌐 Core
import 'package:money_mind_mobile/api/services/api_service.dart';
import 'package:money_mind_mobile/utils/http_override.dart';

// 🔐 Auth
import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart';
import 'package:money_mind_mobile/features/auth/repositories/auth_repository.dart';
import 'package:money_mind_mobile/features/auth/screens/login_screen.dart';

// 🏠 Home
import 'package:money_mind_mobile/features/home/screens/home_screen.dart';

// 📂 Categories
import 'package:money_mind_mobile/features/categories/providers/category_provider.dart';
import 'package:money_mind_mobile/data/repositories/category_repository_impl.dart';
import 'package:money_mind_mobile/domain/usecases/get_categories_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/create_category_usecase.dart';

// ➕ Income
import 'package:money_mind_mobile/features/incomes/providers/income_provider.dart';
import 'package:money_mind_mobile/data/repositories/income_repository_impl.dart';
import 'package:money_mind_mobile/domain/usecases/create_income_usecase.dart';

// ➖ Expense
import 'package:money_mind_mobile/features/expenses/providers/expense_provider.dart';
import 'package:money_mind_mobile/data/repositories/expense_repository_impl.dart';
import 'package:money_mind_mobile/domain/usecases/create_expense_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_expenses_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_expense_by_id_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/update_expense_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/delete_expense_usecase.dart';

// 💰 Budget
import 'package:money_mind_mobile/features/budgets/providers/budget_provider.dart';
import 'package:money_mind_mobile/data/repositories/budget_repository_impl.dart';
import 'package:money_mind_mobile/domain/usecases/create_budget_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_budgets_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_budget_by_id_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/update_budget_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/delete_budget_usecase.dart';

// 📊 Dashboard
import 'package:money_mind_mobile/features/dashboard/providers/chart_provider.dart';
import 'package:money_mind_mobile/features/dashboard/providers/filtered_chart_provider.dart';
import 'package:money_mind_mobile/data/repositories/dashboard_repository_impl.dart';
import 'package:money_mind_mobile/domain/usecases/get_monthly_data_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_ingresos_por_presupuesto_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_gastos_por_presupuesto_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/get_budgets_by_user_and_month_usecase.dart';

// 🌱 Recomendaciones
import 'package:money_mind_mobile/features/recomendaciones/providers/recomendacion_provider.dart';

// 🔔 Notificaciones SignalR
import 'package:money_mind_mobile/domain/repositories/notification_repository.dart';
import 'package:money_mind_mobile/data/repositories/notification_repository_impl.dart'; // IMPLEMENTACIÓN ACTUALIZADA

void main() {
  HttpOverrides.global = MyHttpOverrides();
  final apiService = ApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Auth ---
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(apiService)),
        ),

        // --- Notificaciones SignalR ---
        Provider<NotificationRepository>(
          create: (_) => NotificationRepositoryImpl(),
          dispose: (context, service) => service.dispose(),
        ),

        // --- Recomendaciones ---
        ChangeNotifierProvider(
          create: (_) => RecomendacionProvider(),
        ),

        // --- Categorías ---
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            GetCategoriesUseCase(CategoryRepositoryImpl(apiService)),
            CreateCategoryUseCase(CategoryRepositoryImpl(apiService)),
          ),
        ),

        // --- Ingresos ---
        ChangeNotifierProvider(
          create: (_) => IncomeProvider(
            CreateIncomeUseCase(IncomeRepositoryImpl(apiService)),
          ),
        ),

        // --- Gastos ---
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            CreateExpenseUseCase(ExpenseRepositoryImpl(apiService)),
            GetExpensesUseCase(ExpenseRepositoryImpl(apiService)),
            GetExpenseByIdUseCase(ExpenseRepositoryImpl(apiService)),
            UpdateExpenseUseCase(ExpenseRepositoryImpl(apiService)),
            DeleteExpenseUseCase(ExpenseRepositoryImpl(apiService)),
          ),
        ),

        // --- Presupuestos ---
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(
            CreateBudgetUseCase(BudgetRepositoryImpl(apiService)),
            GetBudgetsUseCase(BudgetRepositoryImpl(apiService)),
            GetBudgetByIdUseCase(BudgetRepositoryImpl(apiService)),
            UpdateBudgetUseCase(BudgetRepositoryImpl(apiService)),
            DeleteBudgetUseCase(BudgetRepositoryImpl(apiService)),
          ),
        ),

        // --- Dashboard general ---
        ChangeNotifierProvider(
          create: (_) => ChartProvider(
            GetMonthlyDataUseCase(DashboardRepositoryImpl(apiService)),
          ),
        ),

        // --- Dashboard filtrado por presupuesto ---
        ChangeNotifierProvider(
          create: (_) => FilteredChartProvider(
            getIngresosPorPresupuestoUseCase: GetIngresosPorPresupuestoUseCase(
              IncomeRepositoryImpl(apiService),
            ),
            getGastosPorPresupuestoUseCase: GetGastosPorPresupuestoUseCase(
              ExpenseRepositoryImpl(apiService),
            ),
            getPresupuestosUseCase: GetBudgetsByUserAndMonthUseCase(
              BudgetRepositoryImpl(apiService),
            ),
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          Widget screen;
          if (authProvider.isCheckingAuth) {
            screen = const SplashScreen();
          } else if (authProvider.isLoggedIn) {
            screen = const HomeScreen();
          } else {
            screen = const LoginScreen();
          }

          return MaterialApp(
            title: 'MoneyMind',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            home: screen,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
