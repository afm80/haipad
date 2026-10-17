import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const brand50 = Color(0xFFFFF7ED);
  static const brand100 = Color(0xFFFFEDD5);
  static const brand500 = Color(0xFFFF6200);
  static const brand600 = Color(0xFFEA580C);
  static const amber300 = Color(0xFFFCD34D);
  static const amber500 = Color(0xFFF59E0B);
  static const orange200 = Color(0xFFFED7AA);
  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red200 = Color(0xFFFECACA);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const rose500 = Color(0xFFF43F5E);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const blue500 = Color(0xFF3B82F6);
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
}

TextStyle cairo(double size,
    {FontWeight weight = FontWeight.w400,
    Color color = AppColors.slate800,
    double? height}) {
  return GoogleFonts.cairo(
      fontSize: size, fontWeight: weight, color: color, height: height);
}

TextStyle tajawal(double size,
    {FontWeight weight = FontWeight.w400,
    Color color = AppColors.slate800,
    double? height}) {
  return GoogleFonts.tajawal(
      fontSize: size, fontWeight: weight, color: color, height: height);
}

/// اسم الموقع: حرف H برتقالي وباقي الاسم داكن.
Widget brandName(double size, {double height = 1.1}) {
  return Text.rich(
    TextSpan(children: [
      TextSpan(
          text: 'H',
          style: cairo(size,
              weight: FontWeight.w800, color: AppColors.brand500, height: height)),
      TextSpan(
          text: 'aipad',
          style: cairo(size,
              weight: FontWeight.w800, color: AppColors.slate900, height: height)),
    ]),
    textDirection: TextDirection.ltr,
  );
}

double pagePadding(double w) => w >= 1024 ? 32 : (w >= 640 ? 24 : 16);

String fmt(int n) =>
    n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

BoxDecoration cardBox({double radius = 24, Color color = Colors.white}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.slate200),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1)),
    ],
  );
}
