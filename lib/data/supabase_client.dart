import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static final SupabaseClientManager _instance = SupabaseClientManager._internal();

  factory SupabaseClientManager() {
    return _instance;
  }

  SupabaseClientManager._internal();

  SupabaseClient get client => Supabase.instance.client;
}
