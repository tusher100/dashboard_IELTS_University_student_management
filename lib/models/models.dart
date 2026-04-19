import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? id;
  final String fullName;
  final String mobileNumber;
  final String course;
  final String paymentPlan;
  final String scholarship;
  final double amountPaid;
  final DateTime? createdAt;

  StudentModel({
    this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.course,
    required this.paymentPlan,
    required this.scholarship,
    required this.amountPaid,
    this.createdAt,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      course: data['course'] ?? '',
      paymentPlan: data['paymentPlan'] ?? '',
      scholarship: data['scholarship'] ?? '',
      amountPaid: (data['amountPaid'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'course': course,
      'paymentPlan': paymentPlan,
      'scholarship': scholarship,
      'amountPaid': amountPaid,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class ReceiptModel {
  final String id;
  final String studentId;
  final String studentName;
  final String mobileNumber;
  final String course;
  final double amount;
  final DateTime date;

  ReceiptModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.mobileNumber,
    required this.course,
    required this.amount,
    required this.date,
  });

  factory ReceiptModel.fromStudent(StudentModel student) {
    return ReceiptModel(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      studentId: student.id ?? '',
      studentName: student.fullName,
      mobileNumber: student.mobileNumber,
      course: student.course,
      amount: student.amountPaid,
      date: DateTime.now(),
    );
  }
}
