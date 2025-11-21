import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String output = "0";    // for display
  String input = "";      // full input string
  double num1 = 0;        // first number
  double num2 = 0;        // second number
  String operator = "";   // + - * /

  void buttonPressed(String value) {
    setState(() {
      // Clear button
      if (value == "C") {
        input = "";
        output = "0";
        num1 = 0;
        num2 = 0;
        operator = "";
        return;
      }

      // If operator is pressed
      if (value == "+" || value == "-" || value == "×" || value == "÷") {
        num1 = double.tryParse(output) ?? 0;
        operator = value;
        input = "";
        return;
      }

      // If equals = pressed
      if (value == "=") {
        num2 = double.tryParse(output) ?? 0;
        double result = 0;

        if (operator == "+") {
          result = num1 + num2;
        } else if (operator == "-") {
          result = num1 - num2;
        } else if (operator == "×") {
          result = num1 * num2;
        } else if (operator == "÷") {
          if (num2 != 0) {
            result = num1 / num2;
          } else {
            output = "Error";
            return;
          }
        }

        output = removeDecimal(result);
        input = "";
        operator = "";
        return;
      }

      // Otherwise input digits
      input += value;
      output = input;
    });
  }

  // Remove .0 for whole numbers
  String removeDecimal(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  Widget calcButton(String text, Color color) {
    return Expanded(
      child: Container(
        height: 80,
        margin: EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          onPressed: () => buttonPressed(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Display Panel
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Text(
                output,
                style: TextStyle(fontSize: 48, color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),

          // Buttons Panel
          Column(
            children: [
              Row(
                children: [
                  calcButton("7", Colors.grey[850]!),
                  calcButton("8", Colors.grey[850]!),
                  calcButton("9", Colors.grey[850]!),
                  calcButton("÷", Colors.orange),
                ],
              ),
              Row(
                children: [
                  calcButton("4", Colors.grey[850]!),
                  calcButton("5", Colors.grey[850]!),
                  calcButton("6", Colors.grey[850]!),
                  calcButton("×", Colors.orange),
                ],
              ),
              Row(
                children: [
                  calcButton("1", Colors.grey[850]!),
                  calcButton("2", Colors.grey[850]!),
                  calcButton("3", Colors.grey[850]!),
                  calcButton("-", Colors.orange),
                ],
              ),
              Row(
                children: [
                  calcButton("0", Colors.grey[850]!),
                  calcButton("C", Colors.blueGrey),
                  calcButton("=", Colors.green),
                  calcButton("+", Colors.orange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
