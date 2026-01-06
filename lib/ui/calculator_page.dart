import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;
  List<String> _history = [];

  void _onDigitPress(String digit) {
    setState(() {
      if (_shouldResetDisplay || _display == '0') {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display.length < 15) {
          _display += digit;
        }
      }
    });
  }

  void _onDecimalPress() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorPress(String operator) {
    setState(() {
      if (_firstOperand != null && _operator != null && !_shouldResetDisplay) {
        _calculate();
      }
      _firstOperand = double.tryParse(_display);
      _operator = operator;
      _expression = '$_display $operator';
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;

    double? secondOperand = double.tryParse(_display);
    if (secondOperand == null) return;

    double result = 0;
    String fullExpression = '$_firstOperand $_operator $secondOperand';

    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand == 0) {
          setState(() {
            _display = 'Error';
            _expression = '';
            _firstOperand = null;
            _operator = null;
          });
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
    }

    setState(() {
      // Format result
      if (result == result.toInt()) {
        _display = result.toInt().toString();
      } else {
        _display = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      
      // Add to history
      _history.insert(0, '$fullExpression = $_display');
      if (_history.length > 10) _history.removeLast();
      
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPress() {
    _calculate();
  }

  void _onClearPress() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onBackspacePress() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onPercentPress() {
    setState(() {
      double? value = double.tryParse(_display);
      if (value != null) {
        value = value / 100;
        _display = value.toString();
      }
    });
  }

  void _onPlusMinusPress() {
    setState(() {
      if (_display != '0') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  void _onSquareRootPress() {
    setState(() {
      double? value = double.tryParse(_display);
      if (value != null && value >= 0) {
        double result = math.sqrt(value);
        if (result == result.toInt()) {
          _display = result.toInt().toString();
        } else {
          _display = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        _shouldResetDisplay = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧮 Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expression
                    Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Result
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Buttons
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    // Row 1
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', onTap: _onClearPress, backgroundColor: Colors.red.shade100, textColor: Colors.red),
                          _buildButton('±', onTap: _onPlusMinusPress, backgroundColor: Colors.grey.shade200),
                          _buildButton('%', onTap: _onPercentPress, backgroundColor: Colors.grey.shade200),
                          _buildButton('÷', onTap: () => _onOperatorPress('÷'), backgroundColor: colorScheme.primary, textColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 2
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7', onTap: () => _onDigitPress('7')),
                          _buildButton('8', onTap: () => _onDigitPress('8')),
                          _buildButton('9', onTap: () => _onDigitPress('9')),
                          _buildButton('×', onTap: () => _onOperatorPress('×'), backgroundColor: colorScheme.primary, textColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 3
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4', onTap: () => _onDigitPress('4')),
                          _buildButton('5', onTap: () => _onDigitPress('5')),
                          _buildButton('6', onTap: () => _onDigitPress('6')),
                          _buildButton('-', onTap: () => _onOperatorPress('-'), backgroundColor: colorScheme.primary, textColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 4
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1', onTap: () => _onDigitPress('1')),
                          _buildButton('2', onTap: () => _onDigitPress('2')),
                          _buildButton('3', onTap: () => _onDigitPress('3')),
                          _buildButton('+', onTap: () => _onOperatorPress('+'), backgroundColor: colorScheme.primary, textColor: Colors.white),
                        ],
                      ),
                    ),
                    // Row 5
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('√', onTap: _onSquareRootPress, backgroundColor: Colors.grey.shade200),
                          _buildButton('0', onTap: () => _onDigitPress('0')),
                          _buildButton('.', onTap: _onDecimalPress),
                          _buildButton('=', onTap: _onEqualsPress, backgroundColor: Colors.green, textColor: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          elevation: 2,
          shadowColor: Colors.black26,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '📜 History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No calculations yet',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _history[index],
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          // Copy result to display
                          final result = _history[index].split('=').last.trim();
                          setState(() {
                            _display = result;
                            _shouldResetDisplay = true;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (_history.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  setState(() => _history.clear());
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Clear History', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
