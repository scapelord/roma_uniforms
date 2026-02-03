import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart'; // IMPORT PAYSTACK
import 'package:roma_shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_client/features/cart/cart_provider.dart';
import 'package:roma_client/services/client_order_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_client/features/auth/auth_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  // Paystack Live Key
  final String _paystackPublicKey = "pk_live_3117e1b5490f76523d666513330ee1dbef1f1155"; 

  String _selectedPaymentMethod = 'MPESA_MANUAL'; // Default
  String _selectedRegion = 'Nairobi CBD';
  bool _isSubmitting = false;

  final Map<String, double> _deliveryRates = {
    'Nairobi CBD': 200,
    'Nairobi Outskirts': 350,
    'Upcountry (Pickup Station)': 500,
  };

  @override
  void initState() {
    super.initState();
  }

  // --- THE CHECKOUT LOGIC ---
  Future<void> _processCheckout() async {
    // 0. AUTH CHECK
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      final loggedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(isRedirect: true),
        ),
      );

      if (loggedIn != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You must be logged in to checkout.")),
          );
        }
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;
    
    // Calculate Total
    final subtotal = ref.read(cartProvider.notifier).grandTotal;
    final deliveryFee = _deliveryRates[_selectedRegion]!;
    final totalAmount = subtotal + deliveryFee;

    setState(() => _isSubmitting = true);

    String? paymentRef; // This will store the transaction code

    try {
      // STRATEGY 1: MANUAL M-PESA
      if (_selectedPaymentMethod == 'MPESA_MANUAL') {
        paymentRef = _manualMpesaCtrl.text;
        await _submitOrderToDatabase(totalAmount, deliveryFee, paymentRef);
      } 
      
      // STRATEGY 2: PAYSTACK (Cards / Auto M-Pesa)
      else if (_selectedPaymentMethod == 'PAYSTACK') {
        try {
          await FlutterPaystackPlus.openPaystackPopup(
            publicKey: _paystackPublicKey,
            customerEmail: "client@roma.com",
            context: context,
            amount: (totalAmount * 100).toString(), // Amount in Kobo/Cents as String
            reference: "ROMA_${DateTime.now().millisecondsSinceEpoch}",
            onClosed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Cancelled / Window Closed")));
            },
            onSuccess: () async {
              paymentRef = "PAYSTACK:SUCCESS";
              await _submitOrderToDatabase(totalAmount, deliveryFee, paymentRef);
            },
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Error: $e")));
        }
      }

      // STRATEGY 3: PAYPAL (Placeholder)
      else if (_selectedPaymentMethod == 'PAYPAL') {
        throw Exception("PayPal integration coming in v2.0");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- DATABASE SAVE ---
  Future<void> _submitOrderToDatabase(double total, double delivery, String refCode) async {
    final cartItems = ref.read(cartProvider);
    
    await ClientOrderService().placeOrder(
      items: cartItems,
      totalAmount: total,
      deliveryCost: delivery,
      deliveryAddress: _addressCtrl.text,
      regionName: _selectedRegion,
      paymentRef: refCode,
    );

    // Success Sequence
    ref.read(cartProvider.notifier).clearCart();
    if (mounted) _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: RomaColors.pitLaneGrey,
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text("POLE POSITION!", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Your order has been placed successfully.\nTrack it in 'My Garage'.", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("RETURN TO PADDOCK", style: TextStyle(color: RomaColors.ferrariRed)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartProvider.notifier).grandTotal;
    final deliveryFee = _deliveryRates[_selectedRegion]!;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        title: Text("CHECKOUT", style: GoogleFonts.orbitron()),
        backgroundColor: RomaColors.pitLaneGrey,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- SECTION 1: DELIVERY ---
            _sectionTitle("LOGISTICS (DELIVERY)"),
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              dropdownColor: RomaColors.pitLaneGrey,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec("Delivery Zone"),
              items: _deliveryRates.keys.map((region) {
                return DropdownMenuItem(
                  value: region,
                  child: Text("$region (KES ${_deliveryRates[region]})"),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedRegion = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec("Exact Location / Pickup Point"),
              validator: (v) => v!.isEmpty ? "Required" : null,
              maxLines: 2,
            ),
            
            const SizedBox(height: 32),

            // --- SECTION 2: PAYMENT SELECTOR ---
            _sectionTitle("PAYMENT METHOD"),
            Row(
              children: [
                _buildPaymentCard("M-Pesa Manual", "MPESA_MANUAL", Icons.phone_android, Colors.green),
                const SizedBox(width: 8),
                _buildPaymentCard("Paystack / Card", "PAYSTACK", Icons.credit_card, Colors.blue),
                const SizedBox(width: 8),
                _buildPaymentCard("PayPal", "PAYPAL", Icons.public, Colors.indigo),
              ],
            ),
            const SizedBox(height: 20),

            // --- SECTION 3: DYNAMIC FIELDS ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildDynamicPaymentFields(),
            ),

            const SizedBox(height: 32),
            const Divider(color: RomaColors.carbonFiber),
            
            // --- SUMMARY ---
            _summaryRow("Subtotal", subtotal),
            _summaryRow("Delivery", deliveryFee),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TOTAL", style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                Text("KES ${total.toStringAsFixed(0)}", style: GoogleFonts.orbitron(fontSize: 20, color: RomaColors.ferrariRed, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 32),
            
            // --- CONFIRM BUTTON ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: RomaColors.ferrariRed),
                onPressed: _isSubmitting ? null : _processCheckout,
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CONFIRM ORDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildDynamicPaymentFields() {
    if (_selectedPaymentMethod == 'MPESA_MANUAL') {
      return Column(
        key: const ValueKey('MPESA'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "Paybill: 123456\nAccount: ROMA",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _manualMpesaCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDec("M-Pesa Transaction Code (e.g. QKH...)"),
            validator: (v) => v!.length < 10 ? "Invalid Code" : null,
          ),
        ],
      );
    } else if (_selectedPaymentMethod == 'PAYSTACK') {
      return Container(
        key: const ValueKey('PAYSTACK'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "You will be prompted to enter your Card or M-Pesa details securely via Paystack.",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        key: const ValueKey('PAYPAL'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text("PayPal is currently unavailable.", style: TextStyle(color: Colors.white54))),
      );
    }
  }

  Widget _buildPaymentCard(String label, String id, IconData icon, Color color) {
    final isSelected = _selectedPaymentMethod == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = id),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : RomaColors.pitLaneGrey,
            border: Border.all(color: isSelected ? color : RomaColors.carbonFiber),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: RomaColors.electricBlue, fontWeight: FontWeight.bold)),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text("KES ${amount.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white)),
        ],
      ),
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
