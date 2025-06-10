import 'package:flutter/material.dart';

const updateProfileUrl =
    'https://dqgprtjilznvtezvihww.supabase.co/functions/v1/update-profile';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxZ3BydGppbHpudnRlenZpaHd3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MjkxMTAwOCwiZXhwIjoyMDU4NDg3MDA4fQ.uJAtHRsLeDJCV2sRrSriH7MqJSoNPYz5dU3ZRq3O9dY';
const picsBucketUrl =
    'https://dqgprtjilznvtezvihww.supabase.co/storage/v1/object/public/barmatepics';


const int colorPaletteVesion = 5; // Zwiększ tę wartość gdy zmieniasz kolory
final availableColors = [
  const MaterialColor(0xFF8E24AA, {
  50: Color(0xFFF8E5FF),
  100: Color(0xFFEABDF4),
  200: Color(0xFFDB91E8),
  300: Color(0xFFCD65DC),
  400: Color(0xFFC044D3),
  500: Color(0xFF8E24AA),  // Piękny, wyrazisty fiolet
  600: Color(0xFF7B1FA2),
  700: Color(0xFF6A1B9A),
  800: Color(0xFF4A148C),
  900: Color(0xFF38006B),
}),
  const MaterialColor(0xFF1976D2, {
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(0xFF1976D2), // Wyrazisty niebieski
    600: Color(0xFF1565C0),
    700: Color(0xFF0D47A1),
    800: Color(0xFF0A3E8F),
    900: Color(0xFF08306B),
  }),

  const MaterialColor(0xFF388E3C, {
    50: Color(0xFFE8F5E8),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF388E3C), // Wyrazisty zielony
    600: Color(0xFF2E7D32),
    700: Color(0xFF1B5E20),
    800: Color(0xFF164D1A),
    900: Color(0xFF103D14),
  }),


  const MaterialColor(0xFFFF5722, {
    50: Color(0xFFFFF3E0),
    100: Color(0xFFFFE0B2),
    200: Color(0xFFFFCC80),
    300: Color(0xFFFFB74D),
    400: Color(0xFFFFA726),
    500: Color(0xFFFF5722), // Wyrazisty pomarańczowy
    600: Color(0xFFE64A19),
    700: Color(0xFFD84315),
    800: Color(0xFFBF360C),
    900: Color(0xFF8D2F0A),
  }),

  const MaterialColor(0xFFD32F2F, {
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFD32F2F), // Wyrazisty czerwony
    600: Color(0xFFC62828),
    700: Color(0xFFB71C1C),
    800: Color(0xFF9C1515),
    900: Color(0xFF7C1010),
  }),

  const MaterialColor(0xFF00796B, {
    50: Color(0xFFE0F2F1),
    100: Color(0xFFB2DFDB),
    200: Color(0xFF80CBC4),
    300: Color(0xFF4DB6AC),
    400: Color(0xFF26A69A),
    500: Color(0xFF00796B), // Wyrazisty teal
    600: Color(0xFF00695C),
    700: Color(0xFF004D40),
    800: Color(0xFF003D33),
    900: Color(0xFF002E26),
  }),

  const MaterialColor(0xFF303F9F, {
    50: Color(0xFFE8EAF6),
    100: Color(0xFFC5CAE9),
    200: Color(0xFF9FA8DA),
    300: Color(0xFF7986CB),
    400: Color(0xFF5C6BC0),
    500: Color(0xFF303F9F), // Wyrazisty indigo
    600: Color(0xFF283593),
    700: Color(0xFF1A237E),
    800: Color(0xFF151B6B),
    900: Color(0xFF101258),
  }),

  const MaterialColor(0xFFE91E63, {
    50: Color(0xFFFCE4EC),
    100: Color(0xFFF8BBD9),
    200: Color(0xFFF48FB1),
    300: Color(0xFFF06292),
    400: Color(0xFFEC407A),
    500: Color(0xFFE91E63), // Wyrazisty różowy
    600: Color(0xFFD81B60),
    700: Color(0xFFC2185B),
    800: Color(0xFFAD1457),
    900: Color(0xFF880E4F),
  }),
];
