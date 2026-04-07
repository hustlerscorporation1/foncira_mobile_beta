import 'supabase_service.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Payment Service
// ══════════════════════════════════════════════════════════════

class PaymentService {
  final SupabaseService _supabase = SupabaseService();

  static const double defaultVerificationPriceFCFA = 150000.0;

  // ── Initiate payment ───────────────────────────────────────
  Future<String?> initiatePayment({
    required String verificationId,
    double? amountFCFA,
    required String paymentMethod,
  }) async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final amount = amountFCFA ?? defaultVerificationPriceFCFA;
      final amountUSD = _supabase.convertFcfaToUsd(amount);

      final response = await _supabase.client
          .from('payments')
          .insert({
            'verification_id': verificationId,
            'amount_fcfa': amount,
            'amount_usd': amountUSD,
            'payment_method': paymentMethod,
            'status': 'en_attente',
            'initiated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  // ── Get payment status ────────────────────────────────────
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    try {
      final response = await _supabase.client
          .from('payments')
          .select('*')
          .eq('id', paymentId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ── Get payments for verification ─────────────────────────
  Future<List<Map<String, dynamic>>> getVerificationPayments(
    String verificationId,
  ) async {
    try {
      final response = await _supabase.client
          .from('payments')
          .select('*')
          .eq('verification_id', verificationId)
          .order('initiated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  // ── Update payment status (agent/admin) ────────────────────
  Future<bool> updatePaymentStatus(
    String paymentId,
    String newStatus, {
    String? providerResponse,
    String? transactionReference,
  }) async {
    try {
      await _supabase.client
          .from('payments')
          .update({
            'status': newStatus,
            if (providerResponse != null) 'provider_response': providerResponse,
            if (transactionReference != null)
              'transaction_reference': transactionReference,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  // ── Mark payment as validated ──────────────────────────────
  Future<bool> validatePayment(String paymentId) async {
    try {
      await _supabase.client
          .from('payments')
          .update({
            'status': 'validee',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      throw Exception('Failed to validate payment: $e');
    }
  }

  // ── Mark payment as failed ────────────────────────────────
  Future<bool> failPayment(String paymentId, String reason) async {
    try {
      await _supabase.client
          .from('payments')
          .update({
            'status': 'echouee',
            'provider_response': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      throw Exception('Failed to mark payment as failed: $e');
    }
  }

  // ── Refund payment ────────────────────────────────────────
  Future<bool> refundPayment(String paymentId) async {
    try {
      await _supabase.client
          .from('payments')
          .update({
            'status': 'remboursee',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      throw Exception('Failed to refund payment: $e');
    }
  }

  // ── Get user payment history ───────────────────────────────
  Future<List<Map<String, dynamic>>> getUserPaymentHistory() async {
    try {
      if (_supabase.currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.client
          .from('payments')
          .select('*, verifications(terrain_title, terrain_location)')
          .eq('user_id', _supabase.currentUserId!)
          .order('initiated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  // ── Get payment methods ────────────────────────────────────
  List<String> getPaymentMethods() {
    return ['mobile_money', 'carte_bancaire'];
  }

  // ── Get payment method label ───────────────────────────────
  String getPaymentMethodLabel(String method) {
    switch (method) {
      case 'mobile_money':
        return 'Mobile Money (MTN, Airtel, Moov)';
      case 'carte_bancaire':
        return 'Carte Bancaire';
      default:
        return method;
    }
  }

  // ── Get payment statuses ───────────────────────────────────
  List<String> getPaymentStatuses() {
    return ['en_attente', 'validee', 'echouee', 'remboursee'];
  }

  // ── Get payment status label ───────────────────────────────
  String getPaymentStatusLabel(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'validee':
        return 'Validée';
      case 'echouee':
        return 'Échouée';
      case 'remboursee':
        return 'Remboursée';
      default:
        return status;
    }
  }
}
