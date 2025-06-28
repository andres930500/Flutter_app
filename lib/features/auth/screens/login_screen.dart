import 'package:flutter/material.dart'; // Importa los widgets y utilidades básicas de Flutter.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión de estado.
import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart'; // Importa el AuthProvider para interactuar con la lógica de autenticación.
import 'package:money_mind_mobile/features/auth/screens/register_screen.dart'; // Importa la pantalla de registro para la navegación.
import 'package:money_mind_mobile/features/home/screens/home_screen.dart'; // Importa la pantalla principal de la aplicación para la navegación post-login.

/// **`LoginScreen`** es la pantalla de interfaz de usuario donde los usuarios
/// pueden iniciar sesión en la aplicación MoneyMind.
///
/// Esta pantalla permite a los usuarios introducir su correo electrónico y contraseña.
/// Utiliza `AuthProvider` para gestionar el estado de autenticación (carga, errores, éxito)
/// y navega a la `HomeScreen` tras un inicio de sesión exitoso o a `RegisterScreen`
/// si el usuario desea crear una nueva cuenta.
class LoginScreen extends StatefulWidget {
  /// Constructor de `LoginScreen`.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// El estado mutable de `LoginScreen`.
class _LoginScreenState extends State<LoginScreen> {
  /// Clave global para el `Form`, utilizada para validar los campos de texto.
  final _formKey = GlobalKey<FormState>();

  /// Variables para almacenar temporalmente el correo electrónico y la contraseña
  /// ingresados por el usuario.
  String _email = '';
  String _password = '';

  /// Controladores de texto para los campos de correo electrónico y contraseña.
  /// Son útiles para manipular el texto programáticamente, como limpiar los campos.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// `initState` se llama una vez cuando el estado es insertado en el árbol.
  ///
  /// Aquí, se asegura que el `AuthProvider` se restablezca a un estado limpio
  /// al entrar a la pantalla de Login. Esto previene que indicadores de carga
  /// o mensajes de error de una sesión anterior persistan.
  @override
  void initState() {
    super.initState();
    // Ejecuta `resetState` después de que el frame inicial ha sido construido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).resetState();
    });
  }

  /// `dispose` se llama cuando el estado es eliminado permanentemente del árbol.
  ///
  /// Se utiliza para liberar los recursos de los `TextEditingController`
  /// para evitar fugas de memoria.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Método `build` que describe la parte de la interfaz de usuario representada por este widget.
  ///
  /// Escucha los cambios en `AuthProvider` para actualizar la UI, mostrando
  /// un indicador de carga durante las operaciones de login y mensajes de error
  /// si la autenticación falla.
  @override
  Widget build(BuildContext context) {
    // Escucha `AuthProvider` para reaccionar a cambios en `isLoading` y `errorMessage`.
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
                    // Título de bienvenida de la aplicación.
                    const Text(
                      'Bienvenido a MoneyMind',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Color verde distintivo.
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtítulo que invita al usuario a iniciar sesión.
                    const Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Campo de texto para el correo electrónico.
                    TextFormField(
                      controller: _emailController, // Vincula el controlador.
                      decoration: InputDecoration(
                        labelText: 'Correo', // Etiqueta del campo.
                        prefixIcon: const Icon(Icons.email), // Icono de correo.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress, // Teclado optimizado para correos.
                      onChanged: (value) => _email = value, // Actualiza la variable `_email`.
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingresa un correo'
                          : null, // Regla de validación.
                    ),
                    const SizedBox(height: 16),

                    // Campo de texto para la contraseña.
                    TextFormField(
                      controller: _passwordController, // Vincula el controlador.
                      decoration: InputDecoration(
                        labelText: 'Contraseña', // Etiqueta del campo.
                        prefixIcon: const Icon(Icons.lock), // Icono de candado.
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      obscureText: true, // Oculta el texto para la contraseña.
                      onChanged: (value) => _password = value, // Actualiza la variable `_password`.
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingresa una contraseña'
                          : null, // Regla de validación.
                    ),

                    const SizedBox(height: 24),

                    // Muestra un indicador de carga o el botón de Iniciar Sesión.
                    authProvider.isLoading // Si `isLoading` es true, muestra el spinner.
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity, // El botón ocupa todo el ancho disponible.
                            height: 50, // Altura fija del botón.
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.login), // Icono de login en el botón.
                              label: const Text('Iniciar Sesión'), // Texto del botón.
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700, // Color de fondo del botón.
                                foregroundColor: Colors.white, // Color del texto y icono.
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                                ),
                              ),
                              onPressed: () async {
                                // Deshabilita el botón si ya hay una operación en curso para evitar clics múltiples.
                                if (authProvider.isLoading) return;

                                // Valida el formulario antes de intentar el login.
                                if (_formKey.currentState!.validate()) {
                                  // Intenta iniciar sesión y espera el resultado.
                                  final success =
                                      await authProvider.login(_email, _password);
                                  if (!mounted) return; // Verifica si el widget sigue montado.

                                  if (success) {
                                    // Limpia los campos de texto al iniciar sesión exitosamente.
                                    _emailController.clear();
                                    _passwordController.clear();
                                    // Navega a la `HomeScreen` reemplazando la pantalla actual.
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const HomeScreen()),
                                    );
                                  } else {
                                    // Muestra un SnackBar con el mensaje de error si el login falla.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          authProvider.errorMessage ??
                                              'Error al iniciar sesión. Inténtalo de nuevo.', // Muestra el error o un mensaje genérico.
                                        ),
                                        backgroundColor:
                                            Colors.redAccent, // Fondo rojo para errores.
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),

                    const SizedBox(height: 20),
                    // Botón para navegar a la pantalla de registro.
                    TextButton(
                      onPressed: () {
                        // Limpia los campos de texto al navegar a `RegisterScreen`.
                        _emailController.clear();
                        _passwordController.clear();
                        // Navega a la `RegisterScreen`.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        '¿No tienes cuenta? Regístrate aquí',
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