import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';// Add this import for fl_chart
import 'package:data_table_2/data_table_2.dart'; // Ensure to add this import
import 'package:flutter/services.dart';

void main() {
  runApp(const CompoundInterestCalculatorApp());
}

class CompoundInterestCalculatorApp extends StatelessWidget {
  const CompoundInterestCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compound Interest Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorForm(),
    );
  }
}

class CalculatorForm extends StatefulWidget {
  const CalculatorForm({Key? key}) : super(key: key);

  @override
  _CalculatorFormState createState() => _CalculatorFormState();
}

class _CalculatorFormState extends State<CalculatorForm> {
  final TextEditingController _initialInvestmentController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _depositAmountController = TextEditingController();

  bool _includeDeposits = false;
  String _compoundFrequency = 'Monthly';

  void _calculateCompoundInterest() {
    double initialInvestment = double.tryParse(_initialInvestmentController.text) ?? 0;
    double interestRate = double.tryParse(_interestRateController.text) ?? 0;
    int years = int.tryParse(_yearsController.text) ?? 0;
    int months = int.tryParse(_monthsController.text) ?? 0;
    double monthlyDeposit = double.tryParse(_depositAmountController.text) ?? 0;

    int totalMonths = years * 12 + months;
    int compoundFrequency = _compoundFrequency == 'Monthly' ? 12 : 1;

    List<Map<String, dynamic>> yearlyBreakdown = [];
    List<Map<String, dynamic>> monthlyBreakdown = [];

    double totalAmount = initialInvestment;
    double accruedInterest = 0;
    double yearlyInterest = 0;

    for (int month = 1; month <= totalMonths; month++) {
      if (_includeDeposits) {
        totalAmount += monthlyDeposit;
      }

      double interestForThisMonth = totalAmount * (interestRate / 100) / 12;
      totalAmount += interestForThisMonth;
      accruedInterest += interestForThisMonth; // Total accrued interest

      monthlyBreakdown.add({
        'period': month,
        'interest': interestForThisMonth,
        'accruedInterest': accruedInterest,
        'balance': totalAmount,
      });

      // If it's the end of the year, add to the yearly breakdown
      if (month % 12 == 0) {
        // Save yearly interest for the year
        yearlyBreakdown.add({
          'period': month ~/ 12, // Year number
          'interest': yearlyInterest + accruedInterest - (yearlyBreakdown.isNotEmpty ? yearlyBreakdown.last['accruedInterest'] : 0), // Total interest for the year
          'accruedInterest': accruedInterest, // Total accrued interest up to now
          'balance': totalAmount,
        });

        // Reset yearlyInterest for the next year
        yearlyInterest = 0; // Ensure yearly interest is reset only after storing
      } else {
        // Accumulate interest for the current year
        yearlyInterest += interestForThisMonth;
      }
    }

// Handle case for the last year if it doesn't end exactly at month 12
    if (totalMonths % 12 != 0) {
      yearlyBreakdown.add({
        'period': totalMonths ~/ 12 + 1,
        'interest': yearlyInterest + accruedInterest - (yearlyBreakdown.isNotEmpty ? yearlyBreakdown.last['accruedInterest'] : 0),
        'accruedInterest': accruedInterest,
        'balance': totalAmount,
      });
    }








    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          futureValue: totalAmount,
          totalInterest: accruedInterest,
          initialInvestment: initialInvestment,
          yearlyBreakdown: yearlyBreakdown,
          monthlyBreakdown: monthlyBreakdown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Interest Calculator'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Investment Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _initialInvestmentController,
                  label: 'Initial Investment',
                  prefix: '€',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _interestRateController,
                  label: 'Interest Rate',
                  suffix: '%',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _yearsController,
                        label: 'Years',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _monthsController,
                        label: 'Months',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSwitchListTile(),
                if (_includeDeposits) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _depositAmountController,
                    label: 'Monthly Deposit',
                    prefix: '€',
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 24),
                _buildDropdownButton(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculateCompoundInterest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Calculate',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      keyboardType: keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
    );
  }

  Widget _buildSwitchListTile() {
    return SwitchListTile(
      title: const Text('Include Monthly Deposits'),
      value: _includeDeposits,
      onChanged: (value) {
        setState(() {
          _includeDeposits = value;
        });
      },
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Compound Frequency',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      value: _compoundFrequency,
      items: ['Monthly', 'Yearly'].map((String frequency) {
        return DropdownMenuItem<String>(
          value: frequency,
          child: Text(frequency),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _compoundFrequency = value!;
        });
      },
    );
  }
}

class ResultPage extends StatefulWidget {
  final double futureValue;
  final double totalInterest;
  final double initialInvestment;
  final List<Map<String, dynamic>> yearlyBreakdown;
  final List<Map<String, dynamic>> monthlyBreakdown;

  const ResultPage({
    Key? key,
    required this.futureValue,
    required this.totalInterest,
    required this.initialInvestment,
    required this.yearlyBreakdown,
    required this.monthlyBreakdown,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showYearly = true;
  bool _showGraph = false;

  // Function to determine the optimal interval based on total bars
  int _calculateOptimalInterval(int totalBars) {
    if (totalBars <= 10) {
      return 1; // Show every label if 10 or fewer bars
    } else if (totalBars <= 20) {
      return 2; // Show every 2nd label if between 11 and 20 bars
    } else if (totalBars <= 50) {
      return 5; // Show every 5th label if between 21 and 50 bars
    } else if (totalBars <= 100) {
      return 10; // Show every 10th label if between 51 and 100 bars
    } else if (totalBars <= 200) {
      return 20; // Show every 20th label if between 101 and 200 bars
    } else if (totalBars <= 400) {
      return 40; // Show every 40th label if between 201 and 400 bars
    } else {
      return 100; // Default return for more than 400 bars
    }
  }

  // Function to format Y-axis labels
  String _formatYAxisLabel(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).ceil()} B'; // Billions
    } else if (value >= 1e6) {
      return '${(value / 1e6).ceil()} M'; // Millions
    } else if (value >= 1e3) {
      return '${(value / 1e3).ceil()} K'; // Thousands
    } else {
      return value.ceil().toString(); // Less than 1000
    }
  }


  @override
  Widget build(BuildContext context) {
    final breakdown = _showYearly ? widget.yearlyBreakdown : widget
        .monthlyBreakdown;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Results'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildResultCard(),
              const SizedBox(height: 24),
              _buildToggleButtons(),
              const SizedBox(height: 24),
              Expanded(
                child: _showGraph ? _buildGraph(breakdown) : _buildTable(
                    breakdown),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('Future Value', widget.futureValue, Colors.green),
            const SizedBox(height: 8),
            _buildResultRow(
                'Total Interest', widget.totalInterest, Colors.blue),
            const SizedBox(height: 8),
            _buildResultRow(
                'Total Deposits', widget.futureValue - widget.totalInterest,
                Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          '€${value.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildToggleButton(
          options: const ['Yearly', 'Monthly'],
          isSelected: [_showYearly, !_showYearly],
          onPressed: (index) => setState(() => _showYearly = index == 0),
        ),
        const SizedBox(width: 16),
        _buildToggleButton(
          options: const ['Table', 'Graph'],
          isSelected: [!_showGraph, _showGraph],
          onPressed: (index) => setState(() => _showGraph = index == 1),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required List<String> options,
    required List<bool> isSelected,
    required Function(int) onPressed,
  }) {
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(8),
      selectedBorderColor: Theme
          .of(context)
          .primaryColor,
      selectedColor: Colors.white,
      fillColor: Theme
          .of(context)
          .primaryColor,
      color: Colors.black54,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 72),
      children: options.map((option) => Text(option)).toList(),
    );
  }

  Widget _buildGraph(List<Map<String, dynamic>> breakdown) {
    return BarChart(
      BarChartData(

        alignment: BarChartAlignment.spaceAround,
        barGroups: breakdown
            .asMap()
            .entries
            .map((entry) {
          int index = entry.key + 1; // Start numbering at 1 instead of 0
          var data = entry.value;

          // Calculate total balance, interest, and deposits
          double totalBalance = data['balance'];
          double totalInterest = data['accruedInterest'];
          double depositValue = totalBalance -
              totalInterest; // Deposits contribution

          // Calculate dynamic bar width based on the total number of bars
          double barWidth = 15; // Default width
          int totalBars = breakdown.length;
          if (_showYearly) {
            barWidth = 30; // Wider bars for yearly view
          } else {
            // Adjust width based on the number of bars to avoid overlapping
            barWidth = (MediaQuery
                .of(context)
                .size
                .width - 40) / totalBars; // 40 for padding
          }

          return BarChartGroupData(
            x: index, // Use index starting from 1
            barRods: [
              BarChartRodData(
                toY: totalBalance,
                // Total balance at the time (including deposits and interest)
                rodStackItems: [
                  BarChartRodStackItem(0, depositValue, Colors.blue),
                  // Deposits part
                  BarChartRodStackItem(
                      depositValue, totalBalance, Colors.green),
                  // Interest part
                ],
                width: barWidth,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Adjust reserved size for bottom titles
              getTitlesWidget: (value, meta) {
                int totalBars = breakdown.length;
                int interval = _calculateOptimalInterval(totalBars);

                // Only display labels at certain intervals
                if (value.toInt() % interval == 0) {
                  return Text(value.toInt().toString());
                } else {
                  return const SizedBox(); // Empty widget for hidden labels
                }
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: false), // Remove top x-axis labels
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: false), // Remove right y-axis labels
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                // Display y-axis labels on the left side
                double maxYValue = breakdown.map((data) => data['balance'])
                    .reduce((a, b) => a > b ? a : b);
                if (value == maxYValue) {
                  return const SizedBox(); // Don't display max Y value
                }
                return Text(_formatYAxisLabel(value));
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.black, width: 1),
            bottom: BorderSide(color: Colors.black, width: 1),
            right: BorderSide(
                color: Colors.black, width: 1), // Add right border
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              var data = breakdown[group.x.toInt() -
                  1]; // Correct indexing since x starts at 1
              double totalBalance = data['balance'];
              double totalInterest = data['accruedInterest'];
              double depositValue = totalBalance - totalInterest;

              // Determine if we are viewing months or years based on the breakdown data
              String timeLabel;
              if (_showYearly) { // If showing yearly data
                timeLabel = 'Year: ${data['period']}';
              } else { // If showing monthly data
                timeLabel = 'Month: ${data['period']}';
              }

              return BarTooltipItem(
                '$timeLabel\nTotal: €${totalBalance.toStringAsFixed(2)}\n',
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'Deposits: €${depositValue.toStringAsFixed(2)}\n',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: 'Interest: €${totalInterest.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> breakdown) {
    return Column(
      children: [
        Container(
          color: Theme
              .of(context)
              .cardColor,
          child: Row(
            children: [
              _buildHeaderCell('Period', flex: 2),
              _buildHeaderCell('          Balance', flex: 3),
              _buildHeaderCell('          Interest', flex: 3),
              _buildHeaderCell('         Accrued', flex: 3),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(3),
              },
              children: breakdown.map((data) {
                return TableRow(
                  children: [
                    _buildTableCell(
                        data['period'].toString(), alignment: Alignment.center),
                    _buildTableCell(data['balance'].toStringAsFixed(2)),
                    _buildTableCell(data['interest'].toStringAsFixed(2)),
                    _buildTableCell(data['accruedInterest'].toStringAsFixed(2)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme
              .of(context)
              .primaryColor),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text,
      {Alignment alignment = Alignment.centerRight}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      alignment: alignment,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}