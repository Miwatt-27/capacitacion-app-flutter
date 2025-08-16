import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoginMode = true; // true = login, false = registro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo e título
                      Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Capacitación Interna',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isLoginMode ? 'Iniciar Sesión' : 'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Campos del formulario
                      if (!_isLoginMode) ...[
                        // Campo nombre (solo para registro)
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isLoginMode && (value?.isEmpty ?? true)) {
                              return 'Ingrese su nombre';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Campo departamento (solo para registro)
                        TextFormField(
                          controller: _departmentController,
                          decoration: InputDecoration(
                            labelText: 'Departamento',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isLoginMode && (value?.isEmpty ?? true)) {
                              return 'Ingrese su departamento';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                      ],

                      // Campo email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo corporativo',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Ingrese su correo';
                          }
                          if (!value!.contains('@')) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Campo contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Ingrese su contraseña';
                          }
                          if (!_isLoginMode && value!.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Botón principal
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isLoginMode ? 'Iniciar Sesión' : 'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Botón cambiar modo
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            _clearForm();
                          });
                        },
                        child: Text(
                          _isLoginMode
                              ? '¿No tienes cuenta? Crear una'
                              : '¿Ya tienes cuenta? Iniciar sesión',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        if (_isLoginMode) {
          // LOGIN
          final result = await authService.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          if (result != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            _showError('Error al iniciar sesión. Verifica tus credenciales.');
          }
        } else {
          // REGISTRO
          final result = await authService.registerWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            department: _departmentController.text.trim(),
          );

          if (result != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            _showError('Error al crear la cuenta. Intenta de nuevo.');
          }
        }
      } catch (e) {
        _showError('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _departmentController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}