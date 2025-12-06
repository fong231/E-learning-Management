import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const UserProfileScreen({super.key, this.currentUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Không dùng controller cho avatar nữa mà dùng biến String và File
  String _currentAvatarUrl = '';
  File? _selectedImageFile; // Biến lưu file ảnh đã chọn từ máy

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller rỗng trước
    _fullnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Gọi hàm load dữ liệu riêng (vì initState không được async)
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Sử dụng widget.currentUser nếu có, nếu không thì lấy từ SharedPreferences
    final Map<String, dynamic> user;

    if (widget.currentUser != null) {
      user = widget.currentUser!;
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      user = await authProvider.getUserProfile();
    }

    final encodedUrl = Uri.encodeFull(user['fullname'] ?? '');
    setState(() {
      _fullnameController.text = user['fullname'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phone_number'] ?? '';
      _currentAvatarUrl =
          user['avatar'] ??
          'https://ui-avatars.com/api/?name=$encodedUrl&background=random&color=fff&format=png';
    });
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- HÀM CHỌN ẢNH TỪ THƯ VIỆN ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      // Mở thư viện ảnh
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path); // Lưu đường dẫn file
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image.'),
        ),
      );
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'fullname': _fullnameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        if (_selectedImageFile != null) 'avatar': _selectedImageFile,
      };

      // Lưu ý: Logic upload ảnh nên được thực hiện trong AuthProvider nếu có file mới
      // Ví dụ: await authProvider.updateProfileWithImage(updatedData, _selectedImageFile);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Giả lập gọi hàm update (bạn cần điều chỉnh hàm này trong AuthProvider để nhận File nếu cần)
      final success = await authProvider.updateProfile(updatedData);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, updatedData);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update failed!'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  String? getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return null;
    }

    if (avatarPath.startsWith('https://ui-avatars.com')) {
      return avatarPath;
    }

    return "${AppConstants.baseUrl}/uploads/$avatarPath";
  }

  @override
  Widget build(BuildContext context) {
    // Xác định ImageProvider để hiển thị (File hay Network)
    ImageProvider? backgroundImage;
    if (_selectedImageFile != null) {
      backgroundImage = FileImage(_selectedImageFile!);
    } else if (_currentAvatarUrl.isNotEmpty) {
      backgroundImage = NetworkImage(getAvatarUrl(_currentAvatarUrl)!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 1. AVATAR SECTION ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: backgroundImage,
                      child: backgroundImage == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        // Gọi hàm chọn ảnh thay vì showDialog
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. FULL NAME (READ ONLY) ---
              TextFormField(
                controller: _fullnameController,
                readOnly: true,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Full Name (Read-only)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFEEEEEE),
                ),
              ),
              const SizedBox(height: 16),

              // --- 3. EMAIL (EDITABLE) ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- 4. PHONE NUMBER (EDITABLE) ---
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 9 || value.length > 11) {
                    return 'Invalid phone number length';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // --- 5. SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
