import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/model.dart';
import '../database/database_helper.dart';
import 'finance.dart';
import 'package:fl_chart/fl_chart.dart'; // ต้องแน่ใจว่าได้ import fl_chart สำหรับ PieChart

class ReportScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  ReportScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<List<FinanceRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = fetchFinanceRecords();
  }

  Future<List<FinanceRecord>> fetchFinanceRecords() async {
    final now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, 1);
    DateTime endDate = DateTime(now.year, now.month + 1, 0);
    return await widget.dbHelper
        .getFinancialRecordsForPeriod(startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Financial Report'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'), // พื้นหลัง
            fit: BoxFit.cover, // ปรับขนาดให้เต็มหน้าจอ
          ),
        ),
        child: FutureBuilder<List<FinanceRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No records for this month.'));
            }

            List<FinanceRecord> records = snapshot.data!;
            records.sort((a, b) => b.date.compareTo(a.date));

            double totalIncome = 0;
            double totalExpenses = 0;

            for (var record in records) {
              if (record.category == 'Income') {
                totalIncome += record.amount;
              } else {
                totalExpenses += record.amount;
              }
            }

            double balance = totalIncome - totalExpenses;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              'Total Income: \$${totalIncome.toStringAsFixed(2)}',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.green),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              'Remaining Balance: \$${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Income and Expenses Chart:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 13),
                  Container(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: totalIncome,
                            color: Colors.green,
                            title:
                                'Income\n\$${totalIncome.toStringAsFixed(2)}',
                            radius: 90,
                            titleStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          PieChartSectionData(
                            value: totalExpenses,
                            color: Colors.red,
                            title:
                                'Expenses\n\$${totalExpenses.toStringAsFixed(2)}',
                            radius: 90,
                            titleStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Transactions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              records[index].description,
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().format(records[index].date),
                              style: TextStyle(fontSize: 14),
                            ),
                            trailing: Text(
                              '${records[index].category == 'Income' ? '+' : '-'}\$${records[index].amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: records[index].category == 'Income'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ModalFinanceForm.showModalInputForm(
            context,
            widget.dbHelper,
            (newCategory) {
              setState(() {});
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FinanceScreen(dbHelper: widget.dbHelper),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.insert_chart),
              onPressed: () {
                // Action for home button
              },
            ),
          ],
        ),
      ),
    );
  }
}
