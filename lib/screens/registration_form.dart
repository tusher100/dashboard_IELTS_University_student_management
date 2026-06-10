import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/admin_provider.dart';
import '../services/pdf_service.dart';

class RegistrationForm extends ConsumerStatefulWidget {
  final bool isPublic;
  final StudentModel? studentToEdit;
  const RegistrationForm({super.key, this.isPublic = false, this.studentToEdit});

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
  TimeOfDay? _selectedTime;
  final _eduInstController = TextEditingController();
  String? _selectedSubject;
  final _raController = TextEditingController();
  final _guardianController = TextEditingController();
  final _relationController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _discountController = TextEditingController();

  String? _selectedInitialMonth;
  final List<String> _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDob = DateTime.now().subtract(const Duration(days: 365 * 18));
  String _selectedGender = 'Male';
  String? _selectedLevel;
  String? _selectedCourse;
  String _selectedSource = 'Facebook';
  
  final Map<String, bool> _hscMonthlyCareSubjects = {
    'Physics': false,
    'Chemistry': false,
    'Biology': false,
    'Higher Math': false,
  };

  double _totalAmount = 0;
  double _admissionFee = 0;
  String _courseDuration = '';
  double _dueAmount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.studentToEdit != null) {
      final s = widget.studentToEdit!;
      _nameController.text = s.fullName;
      _mobileController.text = s.mobileNumber;
      _emailController.text = s.email;
      _batchNameController.text = s.batchName;
      _eduInstController.text = s.educationalInstitution;
      _raController.text = s.ra;
      _guardianController.text = s.guardianName;
      _relationController.text = s.relation;
      _selectedDate = s.date;
      _selectedDob = s.dob;
      _selectedGender = s.gender;
      _selectedSource = s.source;
      
      // Parse course
      if (s.course.contains(' - ')) {
        final parts = s.course.split(' - ');
        _selectedLevel = parts[0];
        _selectedCourse = parts.sublist(1).join(' - ');
      } else {
        _selectedCourse = s.course;
      }
      
      // Parse time
      if (s.time.isNotEmpty) {
        try {
           final timeParts = s.time.split(' ');
           final hm = timeParts[0].split(':');
           int hour = int.parse(hm[0]);
           int minute = int.parse(hm[1]);
           if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
           if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
           _selectedTime = TimeOfDay(hour: hour, minute: minute);
        } catch (e) {}
      }

      // Parse subject
      if (['Science', 'Humanities', 'Business'].contains(s.subject)) {
        _selectedSubject = s.subject;
      } else if (s.subject.isNotEmpty && _selectedLevel == 'HSC' && _selectedCourse == 'Monthly Care') {
        final subjects = s.subject.split(', ');
        for (var sub in subjects) {
           if (_hscMonthlyCareSubjects.containsKey(sub)) {
             _hscMonthlyCareSubjects[sub] = true;
           }
        }
      }
      
      _paidAmountController.text = s.paidAmount.toStringAsFixed(0);
      _discountController.text = s.discount.toStringAsFixed(0);
      _totalAmount = s.totalAmount - s.paymentHistory.fold(0.0, (sum, p) => p.title.contains('Admission') ? sum + p.amount : sum); // Approximate handling
      _dueAmount = s.dueAmount;
      _courseDuration = s.courseDuration;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _batchNameController.dispose();
    _eduInstController.dispose();
    _raController.dispose();
    _guardianController.dispose();
    _relationController.dispose();
    _paidAmountController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    final center = ref.read(coachingCenterProvider) ?? 'IELTS University';
    Map<String, CourseData> courses;
    if (center == 'IELTS University') {
      courses = CourseData.ieltsCourses;
    } else {
      if (_selectedLevel == 'HSC') {
        courses = CourseData.igniteHscCourses;
      } else if (_selectedLevel == 'SSC') {
        courses = CourseData.igniteSscCourses;
      } else {
        courses = {};
      }
    }

    if (_selectedCourse != null) {
      final courseData = courses[_selectedCourse];
      if (courseData != null) {
        if (_selectedLevel == 'HSC' && _selectedCourse == 'Monthly Care') {
          int count = _hscMonthlyCareSubjects.values.where((v) => v).length;
          _totalAmount = count == 4 ? 3500 : (count * 1000).toDouble();
          _admissionFee = 1000;
          _courseDuration = 'Monthly';
        } else {
          _totalAmount = courseData.price.toDouble();
          _admissionFee = courseData.admissionFee.toDouble();
          _courseDuration = courseData.duration;
        }
      }
    } else {
      _totalAmount = 0;
      _admissionFee = 0;
      _courseDuration = '';
    }

    double paid = double.tryParse(_paidAmountController.text) ?? 0;
    double discount = double.tryParse(_discountController.text) ?? 0;
    _dueAmount = (_totalAmount + _admissionFee) - paid - discount;
    if (_dueAmount < 0) _dueAmount = 0;
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

    String finalSubject = _selectedSubject ?? '';
    if ((ref.read(coachingCenterProvider) ?? 'IELTS University') == 'Ignite Academic' && _selectedCourse == 'Monthly Care' && _selectedLevel == 'HSC') {   finalSubject = _hscMonthlyCareSubjects.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(', ');
      if (finalSubject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one subject for Monthly Care')),
        );
        return;
      }
    }

    double initialPaid = double.tryParse(_paidAmountController.text) ?? 0;
    List<PaymentRecord> initialHistory = [];
    String initialMonthTitle = _selectedInitialMonth != null ? '$_selectedInitialMonth Month' : 'Initial Course Fee';

    if (initialPaid > 0) {
      if (_admissionFee > 0 && initialPaid <= _admissionFee) {
        initialHistory.add(PaymentRecord(title: 'Admission Fee', amount: initialPaid, date: DateTime.now()));
      } else if (_admissionFee > 0 && initialPaid > _admissionFee) {
        initialHistory.add(PaymentRecord(title: 'Admission Fee', amount: _admissionFee, date: DateTime.now()));
        initialHistory.add(PaymentRecord(title: initialMonthTitle, amount: initialPaid - _admissionFee, date: DateTime.now()));
      } else {
        initialHistory.add(PaymentRecord(title: initialMonthTitle, amount: initialPaid, date: DateTime.now()));
      }
    }

    final student = StudentModel(
      date: _selectedDate,
      fullName: _nameController.text,
      dob: _selectedDob,
      gender: _selectedGender,
      mobileNumber: _mobileController.text,
      email: _emailController.text,
      course: (ref.read(coachingCenterProvider) == 'Ignite Academic' && _selectedLevel != null) 
          ? '$_selectedLevel - $_selectedCourse' 
          : _selectedCourse!,
      batchName: _batchNameController.text,
      time: _selectedTime?.format(context) ?? '',
      educationalInstitution: _eduInstController.text,
      subject: finalSubject,
      ra: _raController.text,
      source: _selectedSource,
      guardianName: _guardianController.text,
      relation: _relationController.text,
      totalAmount: _totalAmount + _admissionFee,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0,
      dueAmount: _dueAmount,
      discount: double.tryParse(_discountController.text) ?? 0,
      courseDuration: _courseDuration,
      isApproved: widget.studentToEdit?.isApproved ?? !widget.isPublic,
      coachingCenter: ref.read(coachingCenterProvider) ?? 'IELTS University',
      paymentHistory: widget.studentToEdit?.paymentHistory ?? initialHistory,
      id: widget.studentToEdit?.id,
    );

    try {
      if (widget.studentToEdit != null) {
        await ref.read(adminActionProvider.notifier).updateStudent(student);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated successfully!')));
          Navigator.pop(context);
        }
        return;
      }

      await ref.read(adminActionProvider.notifier).addStudent(student);
      
      if (!context.mounted) return;

      if (widget.isPublic) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text('Your admission form has been received and is pending approval. Our authority will contact you soon.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
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
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _batchNameController.clear();
    _eduInstController.clear();
    _raController.clear();
    _guardianController.clear();
    _relationController.clear();
    _paidAmountController.clear();
    _discountController.clear();
    setState(() {
      _selectedInitialMonth = null;
      _selectedSubject = null;
      _selectedTime = null;
      _selectedCourse = null;
      _selectedLevel = null;
      _hscMonthlyCareSubjects.updateAll((key, value) => false);
      _totalAmount = 0;
      _admissionFee = 0;
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
        
        final coachingCenter = ref.watch(coachingCenterProvider) ?? 'IELTS University';
        final primaryColor = coachingCenter == 'IELTS University' ? const Color(0xFFD81B60) : const Color(0xFF38A169);

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
                    _buildSectionTitle('Personal Information', primaryColor),
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
                    _buildSectionTitle('Course & Batch Details', primaryColor),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        if ((ref.watch(coachingCenterProvider) ?? 'IELTS University') == 'Ignite Academic')
                          _buildDropdownField('Level', ['SSC', 'HSC'], _selectedLevel ?? 'HSC', (val) {
                            setState(() {
                              _selectedLevel = val;
                              _selectedCourse = null;
                              _updateCalculations();
                            });
                          }, fieldWidth),
                        _buildCourseDropdown(fieldWidth),
                        _buildTextField('Batch Name', _batchNameController, Icons.groups, width: fieldWidth),
                        _buildTimePickerField('Preferred Time', _selectedTime, (time) => setState(() => _selectedTime = time), fieldWidth),
                        _buildTextField('Educational Institution', _eduInstController, Icons.school, width: fieldWidth),
                        if (_selectedLevel == 'HSC' && _selectedCourse == 'Monthly Care')
                          SizedBox(
                            width: fieldWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Select Subjects (Tk 1000/each, 4 for Tk 3500)', 
                                     style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ..._hscMonthlyCareSubjects.keys.map((subject) {
                                  return CheckboxListTile(
                                    title: Text(subject, style: GoogleFonts.montserrat(fontSize: 14)),
                                    value: _hscMonthlyCareSubjects[subject],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _hscMonthlyCareSubjects[subject] = value ?? false;
                                        _updateCalculations();
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  );
                                }),
                              ],
                            ),
                          )
                        else
                          _buildDropdownField('Subject', ['Science', 'Humanities', 'Business'], _selectedSubject, (val) => setState(() => _selectedSubject = val), fieldWidth),
                        _buildTextField('R/A', _raController, Icons.info_outline, width: fieldWidth),
                      ],
                    ),
                    const SizedBox(height: 48),
                    _buildSectionTitle('Guardian & Reference', primaryColor),
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
                    _buildSectionTitle('Payment Details', primaryColor),
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
                            _buildInfoDisplay('Monthly Fee', 'Tk ${_totalAmount.toStringAsFixed(0)}', Colors.blue),
                            if (_admissionFee > 0) ...[
                              const SizedBox(height: 16),
                              _buildInfoDisplay('Admission Fee', 'Tk ${_admissionFee.toStringAsFixed(0)}', Colors.orange),
                            ],
                            const SizedBox(height: 16),
                            _buildInfoDisplay('Duration', _courseDuration, Colors.purple),
                          ] else 
                            Row(
                              children: [
                                Expanded(child: _buildInfoDisplay('Monthly Fee', 'Tk ${_totalAmount.toStringAsFixed(0)}', Colors.blue)),
                                if (_admissionFee > 0) ...[
                                  const SizedBox(width: 24),
                                  Expanded(child: _buildInfoDisplay('Admission Fee', 'Tk ${_admissionFee.toStringAsFixed(0)}', Colors.orange)),
                                ],
                                const SizedBox(width: 24),
                                Expanded(child: _buildInfoDisplay('Duration', _courseDuration, Colors.purple)),
                              ],
                            ),
                          const SizedBox(height: 24),
                          if (isMobile) ...[
                             _buildTextField('Paid Amount', _paidAmountController, Icons.payments, onChanged: (_) => _updateCalculations(), width: fieldWidth),
                             const SizedBox(height: 16),
                             _buildDropdownField('Payment Month', _months, _selectedInitialMonth, (val) => setState(() => _selectedInitialMonth = val), fieldWidth),
                             const SizedBox(height: 16),
                             _buildTextField('Scholarship/Discount', _discountController, Icons.discount, onChanged: (_) => _updateCalculations(), width: fieldWidth),
                          ] else
                            Row(
                              children: [
                                Expanded(child: _buildTextField('Paid Amount', _paidAmountController, Icons.payments, onChanged: (_) => _updateCalculations(), width: fieldWidth)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdownField('Payment Month', _months, _selectedInitialMonth, (val) => setState(() => _selectedInitialMonth = val), fieldWidth)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildTextField('Scholarship/Discount', _discountController, Icons.discount, onChanged: (_) => _updateCalculations(), width: fieldWidth)),
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
                        child: Text(
                          widget.studentToEdit != null ? 'UPDATE STUDENT' : (widget.isPublic ? 'SUBMIT ADMISSION FORM' : 'REGISTER & GENERATE RECEIPT'), 
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
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

  Widget _buildSectionTitle(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Container(height: 4, width: 40, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
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
  Widget _buildTimePickerField(String label, TimeOfDay? value, Function(TimeOfDay) onSelected, [double? width]) {
    return SizedBox(
      width: width ?? 300,
      child: InkWell(
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: value ?? TimeOfDay.now(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                child: child!,
              );
            },
          );
          if (picked != null) {
            // Force 15m intervals
            int minute = (picked.minute / 15).round() * 15;
            int hour = picked.hour;
            if (minute == 60) {
              minute = 0;
              hour = (hour + 1) % 24;
            }
            onSelected(TimeOfDay(hour: hour, minute: minute));
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.access_time, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(value?.format(context) ?? 'Select Time'),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged, [double? width]) {
    return SizedBox(
      width: width ?? 300,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
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
    final center = ref.watch(coachingCenterProvider) ?? 'IELTS University';
    Map<String, CourseData> courses;
    if (center == 'IELTS University') {
      courses = CourseData.ieltsCourses;
    } else {
      courses = _selectedLevel == 'SSC' ? CourseData.igniteSscCourses : CourseData.igniteHscCourses;
    }

    return SizedBox(
      width: width ?? 300,
      child: DropdownButtonFormField<String>(
        value: courses.containsKey(_selectedCourse) ? _selectedCourse : null,
        isExpanded: true,
        items: courses.keys.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
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
