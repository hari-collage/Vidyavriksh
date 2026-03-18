import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user_model.dart';
import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class AuthScreen extends StatefulWidget {
  final String role;

  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _subjectExpertiseController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Uint8List? _defaultProfileImageBytes;
  Uint8List? _selectedProfileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadDefaultProfileImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _subjectExpertiseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _selectedProfileImageBytes = bytes;
    });
  }

  Future<void> _loadDefaultProfileImage() async {
    final isTeacher = widget.role.toLowerCase() == 'teacher';
    final assetKeys = isTeacher
        ? const ['assets/teacher_1.png', 'teacher_1.png']
        : const ['assets/student.png', 'student.png'];
    ByteData? byteData;

    for (final key in assetKeys) {
      try {
        byteData = await rootBundle.load(key);
        break;
      } catch (_) {
        // Try next key.
      }
    }

    if (byteData == null) return;

    setState(() {
      _defaultProfileImageBytes = byteData!.buffer.asUint8List();
    });
  }

  void _loginWithDemoAccount() {
    final isTeacher = widget.role.toLowerCase() == 'teacher';

    final demoName = isTeacher ? 'shikshak' : 'user';
    final demoPhone = isTeacher ? '4756453647' : '2736475647';
    final demoSubject = isTeacher ? 'maths' : '';
    final demoEmail = isTeacher ? 'shikshak@gmail.com' : 'user@gmail.com';
    const demoPassword = '123456';

    setState(() {
      _isLogin = true;
      _nameController.text = demoName;
      _phoneController.text = demoPhone;
      _subjectExpertiseController.text = demoSubject;
      _emailController.text = demoEmail;
      _passwordController.text = demoPassword;
      _confirmPasswordController.text = demoPassword;
      _selectedProfileImageBytes = null;
    });

    DataService.signupUser(
      AppUser(
        role: widget.role,
        displayName: demoName,
        email: demoEmail,
        password: demoPassword,
        phoneNumber: demoPhone,
        courseName: isTeacher ? demoSubject : '',
        subjectExpertise: isTeacher ? demoSubject : 'General',
        bio: isTeacher ? 'Teacher at VidyaVriksh' : 'Student at VidyaVriksh',
        profileImageBytes: _defaultProfileImageBytes,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      isTeacher ? '/teacher-dashboard' : '/home',
      (route) => false,
    );
  }

  void _submit() {
    final isTeacher = widget.role.toLowerCase() == 'teacher';
    final typedName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();
    final subjectExpertise = _subjectExpertiseController.text.trim();
    final emailPrefix = email.split('@').first.trim();
    final displayName = typedName.isNotEmpty
        ? typedName
        : (emailPrefix.isNotEmpty ? emailPrefix : widget.role);

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    if (_isLogin) {
      final user = DataService.loginUser(
        role: widget.role,
        email: email,
        password: password,
      );

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check role/email/password.'),
          ),
        );
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        isTeacher ? '/teacher-dashboard' : '/home',
        (route) => false,
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and Re-Enter Password must be same.'),
        ),
      );
      return;
    }

    final profileImageBytes =
        _selectedProfileImageBytes ?? _defaultProfileImageBytes;

    if (profileImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load profile picture. Please choose one.'),
        ),
      );
      return;
    }

    DataService.signupUser(
      AppUser(
        role: widget.role,
        displayName: displayName,
        email: email,
        password: password,
        phoneNumber: phone,
        courseName: isTeacher ? subjectExpertise : '',
        subjectExpertise: isTeacher ? subjectExpertise : 'General',
        bio: isTeacher ? 'Teacher at VidyaVriksh' : 'Student at VidyaVriksh',
        profileImageBytes: profileImageBytes,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      isTeacher ? '/teacher-dashboard' : '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.role.toLowerCase() == 'teacher';

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('${widget.role} Login / Signup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.role,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = true;
                                });
                              },
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = false;
                                });
                              },
                              child: const Text('Signup'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loginWithDemoAccount,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Demo Account'),
                      ),
                      const SizedBox(height: 16),
                      if (!_isLogin)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (!_isLogin)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone No',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (!_isLogin && isTeacher)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _subjectExpertiseController,
                            decoration: const InputDecoration(
                              labelText: 'Subject Expertise',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (!_isLogin)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Profile Picture',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.teal,
                                backgroundImage: (_selectedProfileImageBytes ??
                                            _defaultProfileImageBytes) !=
                                        null
                                    ? MemoryImage(
                                        _selectedProfileImageBytes ??
                                            _defaultProfileImageBytes!,
                                      )
                                    : null,
                                child: (_selectedProfileImageBytes ??
                                            _defaultProfileImageBytes) ==
                                        null
                                    ? const Icon(
                                        Icons.person,
                                        size: 34,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _pickProfileImage,
                                child: const Text('Choose Profile Picture'),
                              ),
                            ],
                          ),
                        ),
                      if (_isLogin)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Use same role/email/password used at signup.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Re-Enter Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
