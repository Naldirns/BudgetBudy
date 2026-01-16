import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/db_helper.dart';
import '../models/party.dart';

class AddPartyScreen extends StatefulWidget {
  static const routeName = '/add-party';
  const AddPartyScreen({Key? key}) : super(key: key);

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final party = Party(
        name: _nameController.text.trim(), phone: _phoneController.text.trim());
    await DBHelper.insertParty(party);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Party')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return null;
                  // Validate Indian phone number (10 digits, starts with 6-9)
                  if (value.length != 10 ||
                      !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Enter valid 10-digit Indian phone';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA80852),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
