import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/user.dart';
import 'user_info_page.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({super.key});

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final List<String> _countries = ['Kazakhstan', 'Russia', 'Ukraine', 'Germany', 'France'];
  String _selectedCountry = 'Kazakhstan';

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  User newUser = User();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _storyController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onClear,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    bool? hidePassword,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(hidePassword! ? Icons.visibility : Icons.visibility_off, color: Colors.black),
              onPressed: onTogglePassword,
            )
          : onClear != null
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onClear,
                )
              : null,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        borderSide: BorderSide(color: Color.fromARGB(255, 10, 45, 73), width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Form'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              focusNode: _nameFocus,
              controller: _nameController,
              autofocus: true,
              onFieldSubmitted: (_) => _fieldFocusChange(context, _nameFocus, _phoneFocus),
              decoration: buildInputDecoration(
                label: 'Full Name *',
                hint: 'What do people call you?',
                icon: Icons.person,
                onClear: () => _nameController.clear(),
              ),
              validator: validateName,
              onSaved: (value) => newUser.name = value!,
            ),
            const SizedBox(height: 10),
            TextFormField(
              focusNode: _phoneFocus,
              controller: _phoneController,
              onFieldSubmitted: (_) => _fieldFocusChange(context, _phoneFocus, _passFocus),
              decoration: buildInputDecoration(
                label: 'Phone Number *',
                hint: 'Where can we reach you?',
                icon: Icons.call,
                onClear: () => _phoneController.clear(),
              ).copyWith(helperText: 'Phone format: (XXX)XXX-XXXX'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'^[()\d -]{1,15}\$'), allow: true),
              ],
              validator: (value) => validatePhoneNumber(value!) ? null : 'Phone number must be entered as (###)###-####',
              onSaved: (value) => newUser.phone = value!,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: buildInputDecoration(
                label: 'Email Address',
                hint: 'Enter an email address',
                icon: Icons.mail,
                onClear: () => _emailController.clear(),
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => newUser.email = value!,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              decoration: buildInputDecoration(
                label: 'Country?',
                hint: '',
                icon: Icons.map,
              ),
              items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country as String;
                  newUser.country = country;
                });
              },
              value: _selectedCountry,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _storyController,
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              decoration: buildInputDecoration(
                label: 'Life Story',
                hint: 'Tell us about yourself',
                icon: Icons.book,
                onClear: () => _storyController.clear(),
              ).copyWith(helperText: 'Keep it short, this is just a demo'),
              onSaved: (value) => newUser.story = value!,
            ),
            const SizedBox(height: 10),
            TextFormField(
              focusNode: _passFocus,
              controller: _passController,
              obscureText: _hidePass,
              maxLength: 8,
              decoration: buildInputDecoration(
                label: 'Password *',
                hint: 'Enter your password',
                icon: Icons.security,
                isPassword: true,
                hidePassword: _hidePass,
                onTogglePassword: () => setState(() => _hidePass = !_hidePass),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmPassController,
              obscureText: _hidePass,
              maxLength: 8,
              decoration: buildInputDecoration(
                label: 'Confirm Password *',
                hint: 'Confirm your password',
                icon: Icons.border_color,
                isPassword: true,
                hidePassword: _hidePass,
                onTogglePassword: () => setState(() => _hidePass = !_hidePass),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _showDialog(name: _nameController.text);
    } else {
      _showMessage(message: 'Form is not valid! Please review and correct');
    }
  }

  String? validateName(String? value) {
    final nameExp = RegExp(r'^[A-Za-z ]+\$');
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    } else if (!nameExp.hasMatch(value)) {
      return 'Please enter alphabetical characters.';
    }
    return null;
  }

  bool validatePhoneNumber(String input) {
    final phoneExp = RegExp(r'^\(\d{3}\)\d{3}-\d{4}\$');
    return phoneExp.hasMatch(input);
  }

  String? _validatePassword(String? value) {
    if (_passController.text.length != 8) {
      return '8 characters required for password';
    } else if (_confirmPassController.text != _passController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _showMessage({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  void _showDialog({required String name}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration successful', style: TextStyle(color: Colors.green)),
        content: Text(
          '$name is now a verified register form',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoPage(userInfo: newUser)),
              );
            },
            child: const Text('Verified', style: TextStyle(color: Colors.green, fontSize: 18.0)),
          ),
        ],
      ),
    );
  }
} 