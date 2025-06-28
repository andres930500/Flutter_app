import 'package:flutter/material.dart'; // Importa los widgets y utilidades básicas de Flutter.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión de estado.
import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart'; // Importa el AuthProvider para interactuar con la lógica de autenticación.
import 'package:money_mind_mobile/data/models/user_model.dart'; // Importa el modelo de usuario.
import 'package:money_mind_mobile/features/auth/screens/login_screen.dart'; // Importa la pantalla de login para la navegación post-registro.

/// **`RegisterScreen`** es la pantalla de interfaz de usuario donde los nuevos usuarios
/// pueden crear una cuenta en la aplicación MoneyMind.
///
/// Esta pantalla recopila el nombre, correo electrónico y contraseña del usuario,
/// validando la entrada y utilizando `AuthProvider` para gestionar el proceso de registro.
/// Tras un registro exitoso, el usuario es redirigido a la `LoginScreen`.
class RegisterScreen extends StatefulWidget {
  /// Constructor de `RegisterScreen`.
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// El estado mutable de `RegisterScreen`.
class _RegisterScreenState extends State<RegisterScreen> {
  /// Clave global para el `Form`, utilizada para validar los campos de texto.
  final _formKey = GlobalKey<FormState>();

  /// Variables para almacenar temporalmente los datos del usuario ingresados.
  String _nombre = '';
  String _correo = '';
  String _password = '';
  String _confirmPassword = ''; // Para la confirmación de la contraseña.

  /// Método privado para manejar el envío del formulario de registro.
  ///
  /// Valida los campos del formulario. Si son válidos, construye un objeto `User`
  /// con los datos ingresados (la `contrasenaHash` se establecerá en el `AuthProvider`
  /// antes de enviar al repositorio) e intenta registrar al usuario a través del `AuthProvider`.
  /// Navega a `LoginScreen` en caso de éxito, o muestra un `SnackBar` en caso de error.
  Future<void> _submit() async {
    // Obtiene la instancia de AuthProvider sin escuchar para evitar reconstrucciones innecesarias.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Valida todos los campos del formulario.
    if (_formKey.currentState!.validate()) {
      // Crea un objeto `User` con los datos del formulario.
      // El `id` se pone en 0 ya que se espera que el backend lo asigne.
      // `contrasenaHash` se dejará vacío aquí, ya que el AuthProvider lo hasheará.
      final newUser = User(
        id: 0, // El ID será asignado por el backend.
        nombre: _nombre,
        correo: _correo,
        contrasenaHash: '', // El hashing se maneja en el AuthProvider.
        fechaRegistro: DateTime.now(), // Fecha de registro actual.
      );

      // Intenta registrar al usuario y espera el resultado.
      final success = await authProvider.register(newUser, _password);
      // Verifica si el widget sigue montado antes de realizar operaciones de UI.
      if (success && mounted) {
        // Navega a la `LoginScreen` reemplazando la pantalla actual.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // Muestra un `SnackBar` con el mensaje de error si el registro falla.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(authProvider.errorMessage ??
                  'Error al registrarse')), // Muestra el error específico o uno genérico.
        );
      }
    }
  }

  /// Método `build` que describe la parte de la interfaz de usuario representada por este widget.
  ///
  /// Construye el formulario de registro con campos para nombre, correo, contraseña y confirmación.
  /// Muestra un indicador de carga durante el proceso de registro.
  @override
  Widget build(BuildContext context) {
    // Escucha `AuthProvider` para reaccionar a cambios en `isLoading`.
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Color de fondo claro para la pantalla.
      body: Center(
        // Centra el contenido principal en la pantalla.
        child: SingleChildScrollView(
          // Permite que el contenido sea desplazable si la pantalla es pequeña.
          padding: const EdgeInsets.all(24), // Espaciado alrededor del contenido.
          child: Card(
            // Una tarjeta visualmente elevada para contener el formulario.
            elevation: 6, // Sombra para dar efecto de elevación.
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)), // Bordes redondeados.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey, // Asocia el `GlobalKey` para la validación del formulario.
                child: Column(
                  mainAxisSize: MainAxisSize.min, // La columna ocupa el espacio mínimo necesario.
                  children: [
                    // Título de la pantalla de registro.
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Color verde distintivo.
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtítulo que invita al usuario a registrarse.
                    const Text(
                      'Regístrate para comenzar a gestionar tus finanzas',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Campo de texto para el nombre.
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre', // Etiqueta del campo.
                        prefixIcon: const Icon(Icons.person), // Icono de persona.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      onChanged: (value) =>
                          _nombre = value.trim(), // Actualiza la variable `_nombre` y elimina espacios.
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingresa tu nombre'
                          : null, // Regla de validación.
                    ),
                    const SizedBox(height: 16),

                    // Campo de texto para el correo electrónico.
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo', // Etiqueta del campo.
                        prefixIcon: const Icon(Icons.email), // Icono de correo.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      keyboardType:
                          TextInputType.emailAddress, // Teclado optimizado para correos.
                      onChanged: (value) =>
                          _correo = value.trim(), // Actualiza la variable `_correo` y elimina espacios.
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu correo';
                        // Expresión regular para validar el formato del correo.
                        final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
                        return emailRegex.hasMatch(value) ? null : 'Correo inválido';
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de texto para la contraseña.
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Contraseña', // Etiqueta del campo.
                        prefixIcon: const Icon(Icons.lock), // Icono de candado.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      obscureText: true, // Oculta el texto para la contraseña.
                      onChanged: (value) =>
                          _password = value, // Actualiza la variable `_password`.
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'La contraseña debe tener al menos 6 caracteres', // Regla de validación.
                    ),
                    const SizedBox(height: 16),

                    // Campo de texto para confirmar la contraseña.
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña', // Etiqueta del campo.
                        prefixIcon: const Icon(Icons.lock_outline), // Icono de candado con contorno.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      obscureText: true, // Oculta el texto.
                      onChanged: (value) =>
                          _confirmPassword = value, // Actualiza la variable `_confirmPassword`.
                      validator: (value) => value == _password
                          ? null
                          : 'Las contraseñas no coinciden', // Regla de validación para coincidencia.
                    ),
                    const SizedBox(height: 24),

                    // Muestra un indicador de carga o el botón de Registrarse.
                    authProvider.isLoading // Si `isLoading` es true, muestra el spinner.
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity, // El botón ocupa todo el ancho.
                            height: 50, // Altura fija del botón.
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.person_add), // Icono de añadir persona.
                              label: const Text('Registrarse'), // Texto del botón.
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700, // Color de fondo del botón.
                                foregroundColor: Colors.white, // Color del texto y icono.
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                                ),
                              ),
                              onPressed:
                                  _submit, // Llama al método `_submit` al presionar.
                            ),
                          ),

                    const SizedBox(height: 16),

                    // Botón para navegar de regreso a la pantalla de login.
                    TextButton(
                      onPressed: () => Navigator.pop(
                          context), // Vuelve a la pantalla anterior (LoginScreen).
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(color: Colors.green), // Color verde.
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}