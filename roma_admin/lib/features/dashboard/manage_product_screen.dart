import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:roma_shared/models/product_model.dart';
import 'package:roma_admin/services/admin_supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageProductScreen extends StatefulWidget {
  final Product? product; // Null = Create, Object = Edit

  const ManageProductScreen({super.key, this.product});

  @override
  State<ManageProductScreen> createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminSupabaseService();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imageCtrl; // For manual URL entry (Phase 1)
  
  String _category = 'Tops'; // Default

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: p?.stockLevel.toString() ?? '100');
    _imageCtrl = TextEditingController(text: p?.images.isNotEmpty == true ? p!.images.first : '');
    if (p != null) _category = p.category;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _service.saveProduct(
        id: widget.product?.id,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        category: _category,
        price: double.parse(_priceCtrl.text),
        stockLevel: int.parse(_stockCtrl.text),
        images: [_imageCtrl.text], // Currently handling 1 URL text input
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        backgroundColor: RomaColors.pitLaneGrey,
        title: Text(widget.product == null ? "NEW PART" : "MODIFY SPECS", style: GoogleFonts.orbitron()),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check, color: RomaColors.ferrariRed))
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField("Product Name", _nameCtrl),
            const SizedBox(height: 16),
            _buildField("Description", _descCtrl, maxLines: 3),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor: RomaColors.pitLaneGrey,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec("Category"),
              items: ['Tops', 'Bottoms', 'Sportswear', 'Outerwear', 'Accessories', 'Footwear', 'Daily Uniform']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildField("Price (KES)", _priceCtrl, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildField("Stock Level", _stockCtrl, isNumber: true)),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text("IMAGES", style: TextStyle(color: RomaColors.electricBlue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Image URL Input (Temporary until we add Image Picker)
            _buildField("Image URL (Paste Supabase Link)", _imageCtrl),
            
            if (_imageCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.network(_imageCtrl.text, height: 150, fit: BoxFit.cover),
              ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildField(String label, TextEditingController ctrl, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDec(label),
      validator: (val) => val!.isEmpty ? "Required" : null,
      onChanged: (val) => setState(() {}), // Rebuild to preview image
    );
  }

  InputDecoration _inputDec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: RomaColors.pitLaneGrey,
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: RomaColors.carbonFiber)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: RomaColors.electricBlue)),
    );
  }
}
