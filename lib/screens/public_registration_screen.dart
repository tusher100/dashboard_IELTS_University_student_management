import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'registration_form.dart';
import '../providers/admin_provider.dart';

class PublicRegistrationScreen extends StatelessWidget {
  const PublicRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Admission Form', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Consumer(
          builder: (context, ref, child) {
            return IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // If we entered via URL, we might want to stay or go back to login
                ref.read(publicViewProvider.notifier).update(false);
                // If it was pushed, pop it
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }
              },
            );
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFF7FAFC),
        child: const RegistrationForm(isPublic: true),
      ),
    );
  }
}
