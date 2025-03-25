import 'package:flutter/material.dart';
import '../database/model.dart';
import '../database/database_helper.dart';
import 'report_screen.dart'; // เพิ่มการ import หน้ารายงาน

class BudgetScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  BudgetScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _budgetLimit = 0;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (_startDate ?? _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveBudget() async {
    if (_startDate != null && _endDate != null && _budgetLimit > 0) {
      Budget budget = Budget(
        limit: _budgetLimit,
        currentExpenses: 0,
        startDate: _startDate!,
        endDate: _endDate!,
      );
      await widget.dbHelper.saveBudget(budget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกงบประมาณเรียบร้อย')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
    }
  }

  Future<void> _deleteBudget() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือว่าต้องการลบงบประมาณนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              widget.dbHelper.deleteBudget(); // เรียกใช้ฟังก์ชันลบงบประมาณ
              Navigator.of(context).pop(true);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบงบประมาณเรียบร้อย')),
      );
      Navigator.pop(context); // ปิดหน้าจอ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งงบประมาณรายจ่าย'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
  width: double.infinity, // ขยายให้กว้างเต็มหน้าจอ
  height: double.infinity, // ขยายให้สูงเต็มหน้าจอ
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/background.jpg'), // พื้นหลัง
      fit: BoxFit.cover, // ปรับขนาดให้เต็มหน้าจอ
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'จำนวนงบประมาณ (บาท)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _budgetLimit = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'วันเริ่มต้น: ${_startDate != null ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}" : ""}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, true),
                          child: const Text('เลือกวันเริ่มต้น'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'วันสิ้นสุด: ${_endDate != null ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}" : ""}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, false),
                          child: const Text('เลือกวันสิ้นสุด'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudget,
                child: const Text('บันทึก'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  primary: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deleteBudget,
                child: const Text('ลบงบประมาณ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  primary: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
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
                // Action for home button
              },
            ),
            IconButton(
              icon: const Icon(Icons.insert_chart),
              tooltip: 'View Reports',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportScreen(dbHelper: widget.dbHelper),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
