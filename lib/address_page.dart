import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/user_service.dart';
import 'services/auth_service.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();

  // Field order: Title → City → Street Address
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;
  String? _editingId;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAddressDialog([Map<String, dynamic>? address]) {
    if (address != null) {
      // Pre-fill for edit
      _isEditing = true;
      _editingId = address['id'];
      _titleController.text = address['title'] ?? '';
      _cityController.text = address['city'] ?? '';
      _addressController.text = address['address'] ?? '';
    } else {
      // Reset for new
      _isEditing = false;
      _editingId = null;
      _titleController.clear();
      _cityController.clear();
      _addressController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isEditing ? 'Edit Address' : 'Add Address',
          style: const TextStyle(color: Colors.white, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column 1: Title (e.g. Home, Work, Office)
              _buildTextField(
                controller: _titleController,
                hint: 'Title (e.g. Home, Work)',
                icon: Icons.label_outline,
              ),
              const SizedBox(height: 12),
              // Column 2: City
              _buildTextField(
                controller: _cityController,
                hint: 'City',
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 12),
              // Column 3: Street Address
              _buildTextField(
                controller: _addressController,
                hint: 'Street Address',
                icon: Icons.signpost_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A249),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _isEditing ? 'Update' : 'Save',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        fillColor: const Color(0xFFE4E4E4),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? 'This field is required' : null,
    );
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final uid = context.read<AuthService>().currentUser?.uid ?? '';
      final addressData = {
        'title': _titleController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
      };

      if (_isEditing && _editingId != null) {
        await context.read<UserService>().updateAddress(uid, _editingId!, addressData);
      } else {
        await context.read<UserService>().addAddress(uid, addressData);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF131313);
    final String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Saved Addresses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: context.read<UserService>().getUserAddresses(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }
            final addresses = snapshot.data ?? [];
            if (addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_outlined, size: 60, color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text('No addresses saved yet.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Tap + to add your first address.', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4E4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: primaryColor, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Title
                            Text(
                              addr['title'] ?? 'Address',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Row 2: City
                            Text(
                              addr['city'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Row 3: Street Address
                            Text(
                              addr['address'] ?? '',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                            tooltip: 'Edit',
                            onPressed: () => _showAddressDialog(addr),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(uid, addr['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _showAddressDialog(),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  void _confirmDelete(String uid, String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address', style: TextStyle(color: Colors.white, fontFamily: 'Georgia')),
        content: const Text('Are you sure you want to remove this address?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserService>().deleteAddress(uid, addressId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
