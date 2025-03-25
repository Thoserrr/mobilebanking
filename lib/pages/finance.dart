import 'dart:ui';
import 'package:flutter/material.dart';
import '../database/model.dart';
import 'package:listmember/database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget_screen.dart'; // เพิ่มการ import สำหรับหน้าบันทึกงบประมาณ
import 'report_screen.dart'; // เพิ่มการ import หน้ารายงาน

class FinanceScreen extends StatefulWidget {
  FinanceScreen({Key? key, required this.dbHelper}) : super(key: key);
  final DatabaseHelper dbHelper;

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<FinanceRecord> records = [];
  String filterOption = 'All'; // ตัวแปรเก็บสถานะของการกรอง

  // ฟังก์ชันสำหรับลบรายการทั้งหมด
  Future<void> _deleteAllRecords() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือว่าต้องการลบรายการทั้งหมด?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบทั้งหมด'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await widget.dbHelper.deleteAllFinanceRecords(); // ลบรายการทั้งหมด
      setState(() {
        records.clear(); // เคลียร์รายการในหน้าจอ
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบรายการทั้งหมดเรียบร้อย')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance Management'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false, // ปิดการแสดงปุ่มย้อนกลับ
        actions: [
          // ปุ่มสำหรับลบรายการทั้งหมด
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'ลบรายการทั้งหมด',
            onPressed: _deleteAllRecords, // เรียกใช้ฟังก์ชันลบ
          ),
          // ปุ่มสำหรับเปิดหน้าตั้งงบประมาณ
          IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: 'ตั้งงบประมาณ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetScreen(dbHelper: widget.dbHelper),
                ),
              );
            },
          ),
          // ปุ่มกรองข้อมูล (Income/Expense/All)
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              setState(() {
                filterOption = result; // เปลี่ยนค่าตัวกรอง
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('แสดงทั้งหมด'),
              ),
              const PopupMenuItem<String>(
                value: 'Income',
                child: Text('แสดงรายได้'),
              ),
              const PopupMenuItem<String>(
                value: 'Expense',
                child: Text('แสดงค่าใช้จ่าย'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/background.jpg'), // ใช้รูปภาพพื้นหลัง
            fit: BoxFit.cover, // ปรับให้เต็มพื้นที่
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // แสดงยอดเงินคงเหลือในวงกลม
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.dbHelper.getStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // คำนวณยอดเงินคงเหลือ
                  double totalIncome = 0;
                  double totalExpense = 0;

                  for (var element in snapshot.data!.docs) {
                    FinanceRecord record = FinanceRecord(
                      amount: element.get('amount'),
                      description: element.get('description'),
                      category: element.get('category'),
                      date: DateTime.parse(element.get('date')),
                      referenceId: element.id,
                    );
                    if (record.category == 'Income') {
                      totalIncome += record.amount;
                    } else if (record.category == 'Expense') {
                      totalExpense += record.amount;
                    }
                  }

                  double remainingBalance = totalIncome - totalExpense;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // วงกลมพื้นหลังเบลอ
                      Container(
                        width: 180, // ขนาดของวงกลม
                        height: 180, // ขนาดของวงกลม
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.2), // ทำให้พื้นหลังเบลอ
                          border: Border.all(
                            color: Colors.blue, // ขอบสีฟ้า
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      // แสดงยอดเงินคงเหลือ
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // จัดกลางในแนวตั้ง
                        children: [
                          const Text(
                            'ยอดเงินคงเหลือ',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${remainingBalance.toStringAsFixed(2)} บาท',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // ใน FinanceScreen
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity, // กำหนดความกว้างให้เต็มที่
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: Offset(0.0, 5.0), // Shadow position
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'งบประมาณที่ตั้งไว้',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Icon(Icons.monetization_on,
                            color: Colors.black, size: 30), // ไอคอนงบประมาณ
                      ],
                    ),
                    const SizedBox(height: 10),

                    // แสดงข้อมูลงบประมาณ
                    StreamBuilder<Budget?>(
                      stream: widget.dbHelper.getBudgetStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text(
                            'ยังไม่มีการตั้งงบประมาณ',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          );
                        }

                        Budget budget = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'งบประมาณ: ${budget.limit} บาท',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 0),

                            // แสดงยอดรวมรายจ่าย
                            StreamBuilder<double>(
                              stream: widget.dbHelper.getTotalExpensesStream(),
                              builder: (context, expenseSnapshot) {
                                if (!expenseSnapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                double totalExpenses = expenseSnapshot.data!;
                                double budgetLimit = budget.limit;

                                // คำนวณเปอร์เซ็นต์การใช้จ่าย
                                double usedPercentage =
                                    (totalExpenses / budgetLimit) * 100;

                                // แสดงยอดรวมรายจ่าย
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ใช้ไป: ${totalExpenses.toStringAsFixed(2)} บาท',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),

                                    // แสดงข้อความเตือนถ้าใช้จ่ายถึง 90% ของงบประมาณ
                                    if (usedPercentage >= 90 &&
                                        usedPercentage < 100)
                                      const Text(
                                        '⚠️ คุณใช้จ่ายเกิน 90% ของงบประมาณที่ตั้งไว้!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              Color.fromARGB(255, 255, 232, 24),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else if (usedPercentage >= 100)
                                      const Text(
                                        '❗️ คุณใช้จ่ายเกินงบประมาณที่ตั้งไว้!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    const SizedBox(height: 5),
                                    Text(
                                      'เริ่มต้น: ${budget.startDate.day}/${budget.startDate.month}/${budget.startDate.year}  สิ้นสุด: ${budget.endDate.day}/${budget.endDate.month}/${budget.endDate.year}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.dbHelper.getStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  records.clear();
                  for (var element in snapshot.data!.docs) {
                    records.add(FinanceRecord(
                      amount: element.get('amount'),
                      description: element.get('description'),
                      category: element.get('category'),
                      date: DateTime.parse(element.get('date')),
                      referenceId: element.id,
                    ));
                  }

                  // กรองข้อมูลตามค่าของ filterOption
                  List<FinanceRecord> filteredRecords = records;
                  if (filterOption == 'Income') {
                    filteredRecords = records
                        .where((record) => record.category == 'Income')
                        .toList();
                  } else if (filterOption == 'Expense') {
                    filteredRecords = records
                        .where((record) => record.category == 'Expense')
                        .toList();
                  }

                  filteredRecords.sort((a, b) => b.date.compareTo(a.date));

                  return ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        elevation: 4,
                        child: ListTile(
                          leading: Icon(
                            filteredRecords[index].category == 'Income'
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: filteredRecords[index].category == 'Income'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(filteredRecords[index].description),
                          subtitle: Text(
                            'Amount: ${filteredRecords[index].category == 'Income' ? '+' : '-'}\$${filteredRecords[index].amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: filteredRecords[index].category == 'Income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(filteredRecords[index].category),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete Record',
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                          'Are you sure you want to delete this record?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (shouldDelete == true) {
                                    await widget.dbHelper.deleteFinanceRecord(
                                        filteredRecords[index].referenceId);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            await ModalFinanceForm.showModalEditForm(
                              context,
                              widget.dbHelper,
                              filteredRecords[index],
                              (newCategory) {
                                setState(() {});
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
                // Action for home button
              },
            ),
            IconButton(
              icon: const Icon(Icons.insert_chart), // เก็บปุ่มดูสรุปไว้
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

class ModalFinanceForm extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Function(String) onCategoryChanged;
  final FinanceRecord? record;

  ModalFinanceForm({
    Key? key,
    required this.dbHelper,
    required this.onCategoryChanged,
    this.record,
  }) : super(key: key);

  @override
  _ModalFinanceFormState createState() => _ModalFinanceFormState();

  static Future<dynamic> showModalInputForm(BuildContext context,
      DatabaseHelper dbHelper, Function(String) onCategoryChanged) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ModalFinanceForm(
          dbHelper: dbHelper,
          onCategoryChanged: onCategoryChanged,
        );
      },
    );
  }

  static Future<dynamic> showModalEditForm(
      BuildContext context,
      DatabaseHelper dbHelper,
      FinanceRecord record,
      Function(String) onCategoryChanged) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ModalFinanceForm(
          dbHelper: dbHelper,
          onCategoryChanged: onCategoryChanged,
          record: record,
        );
      },
    );
  }
}

class _ModalFinanceFormState extends State<ModalFinanceForm> {
  String _description = '';
  double _amount = 0;
  String _category = 'Income';

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _description = widget.record!.description;
      _amount = widget.record!.amount;
      _category = widget.record!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Center(
              child: Text(
                'Finance Record Input Form',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  autofocus: true,
                  cursorColor: Colors.blue, // เปลี่ยนสี Cursor เป็นสีฟ้า
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                        color: Colors.blue), // เปลี่ยนสี Label เป็นสีฟ้า
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue), // เปลี่ยนสีขอบเป็นสีฟ้า
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.blue), // เปลี่ยนสีขอบเป็นสีฟ้าเมื่อเลือก
                    ),
                  ),
                  initialValue: _description,
                  onChanged: (value) {
                    _description = value;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.blue, // เปลี่ยนสี Cursor เป็นสีฟ้า
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                        color: Colors.blue), // เปลี่ยนสี Label เป็นสีฟ้า
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue), // เปลี่ยนสีขอบเป็นสีฟ้า
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.blue), // เปลี่ยนสีขอบเป็นสีฟ้าเมื่อเลือก
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _amount.toString(),
                  onChanged: (value) {
                    _amount = double.tryParse(value) ?? 0;
                  },
                ),
              ),
              DropdownButton<String>(
                value: _category,
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                    widget.onCategoryChanged(_category);
                  });
                },
                items: <String>['Income', 'Expense']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: ElevatedButton(
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // เปลี่ยนสีปุ่ม Save เป็นสีฟ้า
                  ),
                  onPressed: () async {
                    if (_description.isNotEmpty && _amount > 0) {
                      var newRecord = FinanceRecord(
                        description: _description,
                        amount: _amount,
                        category: _category,
                        date: DateTime.now(),
                        referenceId: widget.record?.referenceId,
                      );
                      if (widget.record == null) {
                        await widget.dbHelper.insertFinanceRecord(newRecord);
                      } else {
                        await widget.dbHelper.updateFinanceRecord(newRecord);
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter valid description and amount.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
