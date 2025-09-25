import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sumadora',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calculate_outlined,
                size: 80,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Calculadora Simple',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calculadora científica: +, -, ×, ÷, ^, √\nCon manejo de errores y operaciones avanzadas\n ***By Jhon Alexander Ramos ***',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Comenzar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  double _result = 0;
  String _operation = '+';
  String _errorMessage = '';
  int? _quotient;
  double? _remainder;

  void _calculate(String operation) {
    // Limpiar mensajes de error y resultados adicionales previos
    _errorMessage = '';
    _quotient = null;
    _remainder = null;
    
    // Validar campos vacíos
    if (_num1Controller.text.trim().isEmpty || _num2Controller.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa ambos números';
      });
      return;
    }
    
    final num1 = double.tryParse(_num1Controller.text.trim());
    final num2 = double.tryParse(_num2Controller.text.trim());
    
    // Validar que los números son válidos
    if (num1 == null || num2 == null) {
      setState(() {
        _errorMessage = 'Por favor, ingresa números válidos';
      });
      return;
    }
    
    setState(() {
      _operation = operation;
      switch (operation) {
        case '+':
          _result = num1 + num2;
          break;
        case '-':
          _result = num1 - num2;
          break;
        case '×':
          _result = num1 * num2;
          break;
        case '÷':
          if (num2 == 0) {
            _errorMessage = 'No se puede dividir entre cero';
            _result = 0;
          } else {
            _result = num1 / num2;
            // Calcular cociente y residuo para números enteros
            if (num1 % 1 == 0 && num2 % 1 == 0) {
              _quotient = num1.toInt() ~/ num2.toInt();
              _remainder = num1 % num2;
            }
          }
          break;
        case '^':
          // Potencia: num1^num2
          if (num1 == 0 && num2 < 0) {
            _errorMessage = 'No se puede elevar 0 a una potencia negativa';
            _result = 0;
          } else if (num1 < 0 && num2 != num2.round()) {
            _errorMessage = 'No se puede elevar un número negativo a una potencia decimal';
            _result = 0;
          } else {
            _result = math.pow(num1, num2).toDouble();
            if (_result.isInfinite) {
              _errorMessage = 'Resultado demasiado grande';
              _result = 0;
            } else if (_result.isNaN) {
              _errorMessage = 'Operación matemática inválida';
              _result = 0;
            }
          }
          break;
        case '√':
          // Radicación: raíz num2 de num1
          if (num2 == 0) {
            _errorMessage = 'El índice de la raíz no puede ser cero';
            _result = 0;
          } else if (num1 < 0 && num2 % 2 == 0) {
            _errorMessage = 'No se puede calcular raíz par de número negativo';
            _result = 0;
          } else if (num1 < 0 && num2 % 1 != 0) {
            _errorMessage = 'No se puede calcular raíz decimal de número negativo';
            _result = 0;
          } else {
            if (num2 == 2) {
              _result = math.sqrt(num1);
            } else {
              _result = math.pow(num1, 1 / num2).toDouble();
            }
            if (_result.isNaN || _result.isInfinite) {
              _errorMessage = 'Operación matemática inválida';
              _result = 0;
            }
          }
          break;
      }
    });
  }


  void _clear() {
    _num1Controller.clear();
    _num2Controller.clear();
    setState(() {
      _result = 0;
      _operation = '+';
      _errorMessage = '';
      _quotient = null;
      _remainder = null;
    });
  }

  String _formatResult(double result) {
    if (result % 1 == 0) {
      // Es un número entero
      return result.toInt().toString();
    } else if (result.abs() >= 1000000 || result.abs() < 0.000001) {
      // Número muy grande o muy pequeño, usar notación científica
      return result.toStringAsExponential(3);
    } else {
      // Número decimal normal, eliminar ceros innecesarios
      String formatted = result.toStringAsFixed(8);
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Calculadora'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _num1Controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Primer número',
                        hintText: 'Ingresa el primer número',
                        prefixIcon: const Icon(Icons.looks_one_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _operation == '+' 
                          ? Icons.add 
                          : _operation == '-' 
                            ? Icons.remove 
                            : _operation == '×'
                              ? Icons.close
                              : _operation == '÷'
                                ? Icons.more_horiz
                                : _operation == '^'
                                  ? Icons.keyboard_arrow_up
                                  : Icons.calculate,
                        color: Colors.blue[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _num2Controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Segundo número',
                        hintText: 'Ingresa el segundo número',
                        prefixIcon: const Icon(Icons.looks_two_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Fila 1: Operaciones básicas
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _calculate('+'),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Sumar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _calculate('-'),
                            icon: const Icon(Icons.remove_circle_outline),
                            label: const Text('Restar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Fila 2: Multiplicación y División
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _calculate('×'),
                            icon: const Icon(Icons.close_outlined),
                            label: const Text('Multiplicar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _calculate('÷'),
                            icon: const Icon(Icons.more_horiz_outlined),
                            label: const Text('Dividir'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.teal[600],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Texto explicativo para operaciones avanzadas
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'Potencia: Num1^Num2  |  Raíz: Raíz Num2 de Num1',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Fila 3: Operaciones avanzadas
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _calculate('^'),
                            icon: const Icon(Icons.keyboard_double_arrow_up_outlined),
                            label: const Text('Potencia'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.indigo[600],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _calculate('√'),
                            icon: const Icon(Icons.calculate_outlined),
                            label: const Text('Raíz'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.brown[600],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Botón de limpiar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.refresh_outlined),
                        label: const Text('Limpiar Todo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty)
              Card(
                elevation: 0,
                color: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red[100]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 36,
                        color: Colors.red[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue[100]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.functions_outlined,
                        size: 36,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Resultado ($_operation)',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatResult(_result),
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_quotient != null && _remainder != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal[200]!),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'División Entera',
                                style: TextStyle(
                                  color: Colors.teal[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Cociente',
                                        style: TextStyle(
                                          color: Colors.teal[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '$_quotient',
                                        style: TextStyle(
                                          color: Colors.teal[800],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Residuo',
                                        style: TextStyle(
                                          color: Colors.teal[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${_remainder!.toInt()}',
                                        style: TextStyle(
                                          color: Colors.teal[800],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }
}