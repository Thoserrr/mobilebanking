import 'package:cloud_firestore/cloud_firestore.dart';
import 'model.dart';

class DatabaseHelper {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection(FinanceRecord.collectionName);

  // Insert a finance record
  Future<void> insertFinanceRecord(FinanceRecord record) async {
    try {
      await collection.add(record.toJson());
    } catch (e) {
      throw Exception('Failed to add finance record: $e');
    }
  }

  // Get a stream of all finance records
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // Delete a finance record
  Future<void> deleteFinanceRecord(String? referenceId) async {
    if (referenceId != null) {
      try {
        await collection.doc(referenceId).delete();
      } catch (e) {
        throw Exception('Failed to delete finance record: $e');
      }
    }
  }

  // Update a finance record
  Future<void> updateFinanceRecord(FinanceRecord newRecord) async {
    if (newRecord.referenceId != null) {
      try {
        await collection.doc(newRecord.referenceId).update({
          'description': newRecord.description,
          'amount': newRecord.amount,
          'category': newRecord.category,
          'date': newRecord.date.toIso8601String(),
        });
      } catch (e) {
        throw Exception('Failed to update finance record: $e');
      }
    }
  }

  // Get financial records for a specific period (weekly/monthly/yearly)
  Future<List<FinanceRecord>> getFinancialRecordsForPeriod(
      DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot snapshot = await collection
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      return snapshot.docs.map((doc) {
        return FinanceRecord(
          description: doc['description'],
          amount: doc['amount'],
          category: doc['category'],
          date: DateTime.parse(doc['date']),
          referenceId: doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get financial records: $e');
    }
  }

  // Calculate total amount for a list of finance records
  double calculateTotalAmount(List<FinanceRecord> records) {
    return records.fold(0.0, (total, record) => total + record.amount);
  }

  // Save a budget to Firestore
  Future<void> saveBudget(Budget budget) async {
    await FirebaseFirestore.instance
        .collection('budgets')
        .doc('monthly_budget')
        .set(budget.toMap());
  }

  // Get the current budget
  Future<Budget?> getBudget() async {
    var doc = await FirebaseFirestore.instance
        .collection('budgets')
        .doc('monthly_budget')
        .get();
    if (doc.exists) {
      return Budget.fromMap(doc.data()!);
    }
    return null;
  }

  // Get a stream of the current budget
  Stream<Budget?> getBudgetStream() async* {
    yield* FirebaseFirestore.instance
        .collection('budgets')
        .doc('monthly_budget')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Budget.fromMap(doc.data()!);
      }
      return null; // No budget found
    });
  }

  Future<void> deleteAllFinanceRecords() async {
    try {
      // ดึงเอกสารทั้งหมดใน collection
      var snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete(); // ลบแต่ละเอกสาร
      }
    } catch (e) {
      throw Exception('Failed to delete all finance records: $e');
    }
  }

  // Stream to get total expenses
  Stream<double> getTotalExpensesStream() {
    return collection
        .where('category', isEqualTo: 'Expense')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold(0.0, (total, doc) {
        return total + (doc['amount'] ?? 0.0);
      });
    });
  }

  // Function to delete budget
  Future<void> deleteBudget() async {
    try {
      await FirebaseFirestore.instance
          .collection('budgets')
          .doc('monthly_budget')
          .delete();
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  // Additional methods can be added here as needed
}
