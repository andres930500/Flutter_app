import 'package:flutter/material.dart';
import 'package:money_mind_mobile/domain/usecases/get_categories_usecase.dart';
import 'package:money_mind_mobile/domain/usecases/create_category_usecase.dart';
import 'package:money_mind_mobile/data/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  CategoryProvider(
    this._getCategoriesUseCase,
    this._createCategoryUseCase,
  );

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// ✅ Cargar categorías desde el backend
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loaded = await _getCategoriesUseCase.execute();
      _categories = loaded;
      print("📦 Categorías cargadas: $_categories");
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cargar categorías: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Crear categoría nueva y refrescar el listado
  Future<bool> createCategory(Category category) async {
    try {
      final success = await _createCategoryUseCase.execute(category);
      if (success) {
        await loadCategories(); // 🔄 Recargar después de crear
      }
      return success;
    } catch (e) {
      print("❌ Error al crear categoría: $e");
      return false;
    }
  }
}

