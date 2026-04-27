import 'package:cloud_firestore/cloud_firestore.dart';

class CourseData {
  final String title;
  final int price;
  final String duration;

  const CourseData({
    required this.title,
    required this.price,
    required this.duration,
  });

  static const Map<String, CourseData> courses = {
    'Pre-IELTS Care': CourseData(title: 'Pre-IELTS Care', price: 12900, duration: '3.5 month'),
    'Spoken+Computer Basic': CourseData(title: 'Spoken+Computer Basic', price: 3900, duration: ''),
    'Spoken': CourseData(title: 'Spoken', price: 2000, duration: ''),
    'Computer Basic': CourseData(title: 'Computer Basic', price: 2000, duration: ''),
    'IELTS Pre': CourseData(title: 'IELTS Pre', price: 8900, duration: '3 month'),
    'IELTS Rapid': CourseData(title: 'IELTS Rapid', price: 7900, duration: '45 days'),
    'ICT+English': CourseData(title: 'ICT+English', price: 3900, duration: ''),
    'ICT': CourseData(title: 'ICT', price: 3000, duration: ''),
    'English': CourseData(title: 'English', price: 3000, duration: ''),
    'Mock Test': CourseData(title: 'Mock Test', price: 500, duration: ''),
    'IELTS Exam Batch': CourseData(title: 'IELTS Exam Batch', price: 2000, duration: '4 mock test'),
    'One to One': CourseData(title: 'One to One', price: 12000, duration: 'monthly'),
    'Kids Spoken': CourseData(title: 'Kids Spoken', price: 1000, duration: 'admission fee'),
    'Kids Spoken Monthly': CourseData(title: 'Kids Spoken Monthly', price: 1500, duration: 'monthly fee'),
  };
}

class StudentModel {
  final String? id;
  final DateTime date;
  final String fullName;
  final DateTime dob;
  final String gender;
  final String mobileNumber;
  final String email;
  final String course;
  final String batchName;
  final String time;
  final String educationalInstitution;
  final String subject;
  final String ra; // Result/Admission?
  final String source; // How they knew about coaching
  final String guardianName;
  final String relation;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final double discount;
  final String courseDuration;
  final DateTime? createdAt;

  StudentModel({
    this.id,
    required this.date,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.mobileNumber,
    required this.email,
    required this.course,
    required this.batchName,
    required this.time,
    required this.educationalInstitution,
    required this.subject,
    required this.ra,
    required this.source,
    required this.guardianName,
    required this.relation,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.discount,
    required this.courseDuration,
    this.createdAt,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      id: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fullName: data['fullName'] ?? '',
      dob: (data['dob'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      email: data['email'] ?? '',
      course: data['course'] ?? '',
      batchName: data['batchName'] ?? '',
      time: data['time'] ?? '',
      educationalInstitution: data['educationalInstitution'] ?? '',
      subject: data['subject'] ?? '',
      ra: data['ra'] ?? '',
      source: data['source'] ?? '',
      guardianName: data['guardianName'] ?? '',
      relation: data['relation'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0.0).toDouble(),
      dueAmount: (data['dueAmount'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      courseDuration: data['courseDuration'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'fullName': fullName,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'mobileNumber': mobileNumber,
      'email': email,
      'course': course,
      'batchName': batchName,
      'time': time,
      'educationalInstitution': educationalInstitution,
      'subject': subject,
      'ra': ra,
      'source': source,
      'guardianName': guardianName,
      'relation': relation,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'discount': discount,
      'courseDuration': courseDuration,
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
  final String batchName;
  final double amount;
  final DateTime date;

  ReceiptModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.mobileNumber,
    required this.course,
    required this.batchName,
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
      batchName: student.batchName,
      amount: student.paidAmount,
      date: DateTime.now(),
    );
  }
}

