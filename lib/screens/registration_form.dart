import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/admin_provider.dart';
import '../services/pdf_service.dart';

class RegistrationForm extends ConsumerStatefulWidget {
  const RegistrationForm({super.key});

  @override
  ConsumerState<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends ConsumerState<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _batchNameController = TextEditingController();
  final _timeController = TextEditingController();
  final _eduInstController = TextEditingController();
  final _subjectController = TextEditingController();
  final _raController = TextEditingController();
  final _guardianController = TextEditingController();
  final _relationController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _discountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDob = DateTime.now().subtract(const Duration(days: 365 * 18));
  String _selectedGender = 'Male';
  String? _selectedCourse;
  String _selectedSource = 'Facebook';
  
  double _totalAmount = 0;
  String _courseDuration = '';
  double _dueAmount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _batchNameController.dispose();
    _timeController.dispose();
    _eduInstController.dispose();
    _subjectController.dispose();
    _raController.dispose();
    _guardianController.dispose();
    _relationController.dispose();
    _paidAmountController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    if (_selectedCourse != null) {
      final courseData = CourseData.courses[_selectedCourse];
      if (courseData != null) {
        _totalAmount = courseData.price.toDouble();
        _courseDuration = courseData.duration;
      }
    }

    double paid = double.tryParse(_paidAmountController.text) ?? 0;
    double discount = double.tryParse(_discountController.text) ?? 0;
    _dueAmount = _totalAmount - paid - discount;
    setState(() {});
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    final student = StudentModel(
      date: _selectedDate,
      fullName: _nameController.text,
      dob: _selectedDob,
      gender: _selectedGender,
      mobileNumber: _mobileController.text,
      email: _emailController.text,
      course: _selectedCourse!,
      batchName: _batchNameController.text,
      time: _timeController.text,
      educationalInstitution: _eduInstController.text,
      subject: _subjectController.text,
      ra: _raController.text,
      source: _selectedSource,
      guardianName: _guardianController.text,
      relation: _relationController.text,
      totalAmount: _totalAmount,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0,
      dueAmount: _dueAmount,
      discount: double.tryParse(_discountController.text) ?? 0,
      courseDuration: _courseDuration,
    );

    try {
      await ref.read(adminProvider).addStudent(student);
      
      // Part Two: Generate Receipt
      ref.read(isPdfGeneratingProvider.notifier).update(true);
      try {
        await PdfService.generateAndPrintReceipt(student);
      } finally {
        ref.read(isPdfGeneratingProvider.notifier).update(false);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student registered successfully!')),
      );
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _batchNameController.clear();
    _timeController.clear();
    _eduInstController.clear();
    _subjectController.clear();
    _raController.clear();
    _guardianController.clear();
    _relationController.clear();
    _paidAmountController.clear();
    _discountController.clear();
    setState(() {
      _selectedCourse = null;
      _totalAmount = 0;
      _dueAmount = 0;
      _courseDuration = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final fieldWidth = isMobile ? constraints.maxWidth : 300.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Registration',
                      style: GoogleFonts.montserrat(
                        fontSize: isMobile ? 20 : 24, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF1A202C)
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Personal Information'),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _buildDateField('Registration Date', _selectedDate, (date) => setState(() => _selectedDate = date), fieldWidth),
                        _buildTextField('Full Name', _nameController, Icons.person, width: fieldWidth),
                        _buildDateField('Date of Birth', _selectedDob, (date) => setState(() => _selectedDob = date), fieldWidth),
                        _buildDropdownField('Gender', ['Male', 'Female', 'Other'], _selectedGender, (val) => setState(() => _selectedGender = val!), fieldWidth),
                        _buildTextField('Mobile Number', _mobileController, Icons.phone, keyboardType: TextInputType.phone, width: fieldWidth),
                        _buildTextField('Email Address', _emailController, Icons.email, keyboardType: TextInputType.emailAddress, width: fieldWidth),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _buildSectionTitle('Course & Batch Details'),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _buildCourseDropdown(fieldWidth),
                        _buildTextField('Batch Name', _batchNameController, Icons.groups, width: fieldWidth),
                        _buildTextField('Preferred Time', _timeController, Icons.access_time, width: fieldWidth),
                        _buildTextField('Educational Institution', _eduInstController, Icons.school, width: fieldWidth),
                        _buildTextField('Subject', _subjectController, Icons.book, width: fieldWidth),
                        _buildTextField('R/A', _raController, Icons.info_outline, width: fieldWidth),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _buildSectionTitle('Guardian & Reference'),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _buildDropdownField('How do you know about us?', ['Alumnus', 'Facebook', 'Friend', 'Newspaper'], _selectedSource, (val) => setState(() => _selectedSource = val!), fieldWidth),
                        _buildTextField('Guardian Name', _guardianController, Icons.person_outline, width: fieldWidth),
                        _buildTextField('Relation', _relationController, Icons.family_restroom, width: fieldWidth),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _buildSectionTitle('Payment Details'),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          if (isMobile) ...[
                            _buildInfoDisplay('Course Fee', 'Tk ${_totalAmount.toStringAsFixed(0)}', Colors.blue),
                            const SizedBox(height: 16),
                            _buildInfoDisplay('Duration', _courseDuration, Colors.purple),
                          ] else 
                            Row(
                              children: [
                                Expanded(child: _buildInfoDisplay('Course Fee', 'Tk ${_totalAmount.toStringAsFixed(0)}', Colors.blue)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildInfoDisplay('Duration', _courseDuration, Colors.purple)),
                              ],
                            ),
                          const SizedBox(height: 24),
                          if (isMobile) ...[
                             _buildTextField('Paid Amount', _paidAmountController, Icons.payments, onChanged: (_) => _updateCalculations(), width: fieldWidth),
                             const SizedBox(height: 16),
                             _buildTextField('Discount (if any)', _discountController, Icons.discount, onChanged: (_) => _updateCalculations(), width: fieldWidth),
                          ] else
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Paid Amount', _paidAmountController, Icons.payments, onChanged: (_) => _updateCalculations(), width: fieldWidth)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildTextField('Discount (if any)', _discountController, Icons.discount, onChanged: (_) => _updateCalculations(), width: fieldWidth)),
                              ],
                            ),
                          const SizedBox(height: 24),
                          _buildInfoDisplay('Due Amount', 'Tk ${_dueAmount.toStringAsFixed(0)}', _dueAmount > 0 ? Colors.red : Colors.green, large: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 64),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(isMobile ? double.infinity : 300, 64),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('REGISTER & GENERATE RECEIPT', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Container(height: 4, width: 40, decoration: BoxDecoration(color: const Color(0xFFD81B60), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, Function(String)? onChanged, double? width}) {
    return SizedBox(
      width: width ?? 300,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onChanged,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime value, Function(DateTime) onSelected, [double? width]) {
    return SizedBox(
      width: width ?? 300,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(1900),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) onSelected(date);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(DateFormat('dd-MM-yyyy').format(value)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value, Function(String?) onChanged, [double? width]) {
    return SizedBox(
      width: width ?? 300,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCourseDropdown([double? width]) {
    return SizedBox(
      width: width ?? 300,
      child: DropdownButtonFormField<String>(
        value: _selectedCourse,
        items: CourseData.courses.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {
          _selectedCourse = val;
          _updateCalculations();
        },
        decoration: InputDecoration(
          labelText: 'Select Course',
          prefixIcon: const Icon(Icons.book, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoDisplay(String label, String value, Color color, {bool large = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.montserrat(fontSize: large ? 24 : 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
